# frozen_string_literal: true

module Gitlab
  module SidekiqLogging
    class WorkerQuotaLogger
      include Singleton
      include LogsJobs

      def exceed_quota_log(job, key, quota)
        payload = parse_job(job)
        payload['job_status'] = 'exceeded_quota'
        payload['message'] = "#{base_message(payload)}: exceeded quota of #{quota} for: #{key}"

        Sidekiq.logger.info payload
      end
    end
  end
end
