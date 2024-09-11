# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module WorkerQuota
      class Server
        def call(worker, job, _)
          yield

          Tracker.new(worker.class, job).track_quota_usage
        end
      end
    end
  end
end
