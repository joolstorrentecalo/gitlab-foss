# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class Description < Base
        def before_create
          update_description_params = MarkdownContentRewriterService.new(
            current_user,
            work_item,
            :description,
            work_item.project,
            target_work_item.project || target_work_item.group
          ).execute

          target_work_item.assign_attributes(update_description_params)
        end

        def post_move_cleanup
          # do it
        end
      end
    end
  end
end
