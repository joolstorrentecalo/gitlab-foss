# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module ConcurrencyLimit
      class Middleware
        def initialize(worker, job)
          @worker = worker
          @job = job

          worker_class = worker.is_a?(Class) ? worker : worker.class
          @worker_class = worker_class.name
        end

        # This will continue the middleware chain if the job should be scheduled
        # It will return false if the job needs to be cancelled
        def schedule
          if should_defer_schedule?
            defer_job!
            return
          end

          yield
        end

        # This will continue the server middleware chain if the job should be
        # executed.
        # It will return false if the job should not be executed.
        def perform
          if should_defer_perform?
            defer_job!
            return
          end

          track_execution(start: true)

          yield
        ensure
          track_execution(start: false)
        end

        private

        attr_reader :job, :worker, :worker_class

        def track_execution(start:)
          Gitlab::Redis::SharedState.with do |r|
            if start
              r.set("gitlab:{#{sidekiq_process_id}}:#{tid}:job_class", worker_class, ex: 3600)
            else
              r.unlink("gitlab:{#{sidekiq_process_id}}:#{tid}:job_class")
            end
          end
        end

        def sidekiq_process_id
          Thread.current[:sidekiq_capsule].identity
        end

        def tid
          # https://github.com/sidekiq/sidekiq/blob/2451d70080db95cb5f69effcbd74381cf3b3f727/lib/sidekiq/logger.rb#L80
          (Thread.current.object_id ^ ::Process.pid).to_s(36)
        end

        def should_defer_schedule?
          return false if Feature.disabled?(:sidekiq_concurrency_limit_middleware, Feature.current_request, type: :ops)
          return false if resumed?
          return false unless ::Gitlab::SidekiqMiddleware::ConcurrencyLimit::WorkersMap.limit_for(worker: worker)

          has_jobs_in_queue?
        end

        def should_defer_perform?
          return false if Feature.disabled?(:sidekiq_concurrency_limit_middleware, Feature.current_request, type: :ops)

          return false if resumed?
          return true if has_jobs_in_queue?

          ::Gitlab::SidekiqMiddleware::ConcurrencyLimit::WorkersMap.over_the_limit?(worker: worker)
        end

        def concurrency_service
          ::Gitlab::SidekiqMiddleware::ConcurrencyLimit::ConcurrencyLimitService
        end

        def resumed?
          current_context['meta.related_class'] == concurrency_service.name
        end

        def has_jobs_in_queue?
          concurrency_service.has_jobs_in_queue?(worker_class)
        end

        def defer_job!
          ::Gitlab::SidekiqLogging::ConcurrencyLimitLogger.instance.deferred_log(job)

          concurrency_service.add_to_queue!(
            job['class'],
            job['args'],
            current_context
          )
        end

        def current_context
          ::Gitlab::ApplicationContext.current
        end
      end
    end
  end
end
