# frozen_string_literal: true

# This class represents the metadata for the pipeline creation process up until it succeeds and is persisted or fails
# It has the "creating" status until it succeeds or fails.
# It stores the data in Redis and it is retained for 5 minutes.
# The structure of the data is:
# {
#   "merge_request:{MERGE_REQUEST_ID}:ci_pipeline_creations: {
#     "CREATION_ID": {
#       "status": "STATUS",
#       "pipeline_id": "PIPELINE_ID"
#     }
#   }
# }
# `pipeline_id` is `nil` until the pipeline has been persisted. The pipeline is always persisted on success
# and on failure when `save_on_errors: true`.
#
# This class is part of ongoing work. At the time of writing, it has only be built for merge request pipelines.
# Follow us on https://gitlab.com/groups/gitlab-org/-/epics/15078 for updates.
#
module Ci
  class PipelineCreationMetadata
    MR_PIPELINE_CREATING_REDIS_KEY = "merge_request:{%{merge_request_id}}:ci_pipeline_creating"
    REDIS_EXPIRATION_TIME = 300

    class << self
      def pipeline_creating_for_merge_request?(merge_request)
        Gitlab::Redis::SharedState.with { |redis| !!redis.get(merge_request_key(merge_request)) }
      end

      def set_creation_finished_for_merge_request(merge_request)
        Gitlab::Redis::SharedState.with { |redis| redis.del(merge_request_key(merge_request)) }
      end

      def set_creation_started_for_merge_request(merge_request)
        Gitlab::Redis::SharedState.with do |redis|
          redis.set(merge_request_key(merge_request), true, ex: REDIS_EXPIRATION_TIME)
        end
      end

      def merge_request_key(merge_request)
        format(MR_PIPELINE_CREATING_REDIS_KEY, merge_request_id: merge_request.id)
      end
    end
  end
end
