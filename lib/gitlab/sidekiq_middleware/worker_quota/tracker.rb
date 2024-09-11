# frozen_string_literal: true

# The Tracker class directly interface with Redis
module Gitlab
  module SidekiqMiddleware
    module WorkerQuota
      class Tracker
        include Sidekiq::ServerMiddleware
        include ::Gitlab::SidekiqMiddleware::WorkerContext

        THROTTLE_DURATION_SECONDS = 600
        TRACKING_WINDOW_SECONDS = 60

        REQUEST_STORE_TRACKED_KEYS = [
          :db_main_duration_s, :db_ci_duration_s, :db_duration_s,
          :db_main_txn_duration_s, :db_ci_txn_duration_s, :db_txn_duration_s
        ].freeze

        attr_reader :worker_name, :job, :worker

        def initialize(worker_class, job)
          @worker = worker_class
          @worker_name = name_from_class(worker_class, job)
          @job = job
        end

        def track_quota_usage
          # keep track of quota usage only when not circuit broken
          return if circuit_broken?(worker_name)

          exceeded = false
          REQUEST_STORE_TRACKED_KEYS.each do |key|
            duration = ::Gitlab::SafeRequestStore[key].to_f
            next if duration == 0

            redis_key = quota_key(worker_name, key)

            total, _ = with_redis do |c|
              c.pipelined do |p|
                p.incrbyfloat(redis_key, duration)
                p.expire(redis_key, TRACKING_WINDOW_SECONDS, nx: true)
              end
            end

            # how to define quotas, main, ci db? or same quota for all dbs?
            # meh, what quotas do we want to set and how fine grain do we want?
            # just db durations?
            quota = worker.get_quotas[key].to_i # rubocop:disable Lint/UselessAssignment -- ignore for now, unimplemented
            quota = 10 # TODO: remove later
            if total > quota
              track_exceeded_quota(job, key, quota)
              exceeded = true
            end
          end

          throttle(worker, exceeded)
        rescue StandardError => e
          Gitlab::ErrorTracking.log_exception(e)
        end

        def concurrency_limits(worker_class)
          worker_name = name_from_class(worker_class, {})
          with_redis { |c| c.get(throttling_key(worker_name)).to_i }
        end

        private

        def quota_key(worker_name, suffix)
          "worker_quota:usage:{#{worker_name}}:#{suffix}"
        end

        def throttled_key(worker_name)
          "worker_quota:throttled:{#{worker_name}}"
        end

        def throttled_count_key(worker_name)
          "worker_quota:throttled_count:{#{worker_name}}"
        end

        def throttling_key(worker_name)
          "worker_quota:throttling_concurrency:{#{worker_name}}"
        end

        def throttled?(worker_name)
          limit = with_redis { |c| c.get(throttling_key(worker_name)) } # rubocop:disable CodeReuse/ActiveRecord -- not AR

          limit.to_i > 0
        end

        def circuit_broken?(worker_name)
          limit = with_redis { |c| c.get(throttling_key(worker_name)) } # rubocop:disable CodeReuse/ActiveRecord -- not AR

          limit.to_i < 0
        end

        def track_exceeded_quota(job, key, quota)
          # TODO: emit metrics

          ::Gitlab::SidekiqLogging::WorkerQuotaLogger.instance.exceed_quota_log(job, key, quota)
        end

        def throttle(worker_name, exceeded)
          times, throttled = with_redis do |c|
            c.mget(throttled_count_key(worker_name), throttled_key(worker_name))
          end

          # early return if worker did not exceed quota and is not being throttled
          return if !exceeded && times.to_i == 0

          # early return if worker is being throttled but has been throttled within the last 60s
          return if times.to_i > 0 && throttled.to_i == 1

          concurrency = with_redis { |c| c.get(throttling_key(worker_name)) }.to_i

          if exceeded
            updated_concurrency = times.to_i == 0 ? 1 : concurrency / 2
            updated_concurrency = -1 if updated_concurrency == 0
          else
            updated_concurrency = concurrency * 2
          end

          puts "UPDATED CONCURRENCY TO #{updated_concurrency}" # rubocop:disable Rails/Output -- temp

          # refresh ttl so we do not adjust throttle for another 1 minute
          wrote_throttled_key = with_redis do |c|
            c.set(throttled_key(worker_name), 1, ex: TRACKING_WINDOW_SECONDS, nx: true)
          end

          return unless wrote_throttled_key

          if times.to_i == 0
            initiate_throttling(worker_name, updated_concurrency)
          else
            update_throttling(worker_name, updated_concurrency)
          end
        end

        def initiate_throttling(worker_name, updated_concurrency)
          with_redis do |c|
            c.pipelined do |p|
              p.set(throttling_key(worker_name), updated_concurrency, ex: THROTTLE_DURATION_SECONDS, nx: true)
              p.set(throttled_count_key(worker_name), 1, ex: THROTTLE_DURATION_SECONDS, nx: true)
            end
          end
        end

        def update_throttling(worker_name, updated_concurrency)
          with_redis do |c|
            c.pipelined do |p|
              p.set(throttling_key(worker_name), updated_concurrency, keepttl: true)
              p.incr(throttled_count_key(worker_name)) # does not refresh ttl
            end
          end
        end

        def with_redis(&)
          ::Gitlab::Redis::RateLimiting.with(&) # rubocop:disable CodeReuse/ActiveRecord -- not AR
        end

        def name_from_class(worker_class, job)
          worker = find_worker(worker_class, job)
          worker.try(:name) || worker.class.name
        end
      end
    end
  end
end
