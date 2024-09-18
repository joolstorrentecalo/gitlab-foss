# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class TimeTracking < Base
        def after_save_commit
          return if work_item.timelogs.empty?

          work_item_id = work_item.id
          target_work_item_id = target_work_item.id

          target_work_item.run_after_commit_or_now do
            WorkItems::CopyTimelogsWorker.perform_async(work_item_id, target_work_item_id)
          end
        end

        def post_move_cleanup
          # do it
        end
      end
    end
  end
end
