# frozen_string_literal: true

module MergeRequests
  module Mergeability
    class CheckMergeTimeService < CheckBaseService
      identifier :merge_time
      description 'Checks whether the specified merge time is active'

      def execute
        merge_after = merge_request.merge_schedule&.merge_after
        return inactive if merge_after.nil?

        if merge_after.future?
          failure
        else
          success
        end
      end

      def skip?
        params[:skip_merge_time_check].present?
      end

      def cacheable?
        false
      end
    end
  end
end
