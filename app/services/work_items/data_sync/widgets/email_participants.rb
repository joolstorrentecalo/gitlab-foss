# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class EmailParticipants < Base
        def after_save_commit
          new_attributes = { id: nil, issue_id: target_work_item.id }

          new_participants = work_item.issue_email_participants.dup

          new_participants.each do |participant|
            participant.assign_attributes(new_attributes)
          end

          IssueEmailParticipant.bulk_insert!(new_participants)
        end

        def post_move_cleanup
          # do it
        end
      end
    end
  end
end
