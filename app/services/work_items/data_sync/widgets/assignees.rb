# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class Assignees < Base
        def before_create
          target_work_item.assignee_ids = work_item.assignee_ids
        end

        def cleanup
          # do it
        end
      end
    end
  end
end
