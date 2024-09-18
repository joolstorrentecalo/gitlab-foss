# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class AwardEmoji < Base
        def after_save_commit
          AwardEmojis::CopyService.new(work_item, target_work_item).execute
        end

        def post_move_cleanup
          # do it
        end
      end
    end
  end
end
