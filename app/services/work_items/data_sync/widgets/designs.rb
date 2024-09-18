# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class Designs < Base
        def after_save_commit
          return unless work_item.designs.present?

          response = DesignManagement::CopyDesignCollection::QueueService.new(
            current_user,
            work_item,
            target_work_item
          ).execute

          log_error(response.message) if response.error?
        end

        def post_move_cleanup
          # do it
        end
      end
    end
  end
end
