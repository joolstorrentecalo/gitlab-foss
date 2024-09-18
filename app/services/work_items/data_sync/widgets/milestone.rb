# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class Milestone < Base
        def before_create
          milestone = matching_milestone(work_item.milestone&.title)
          target_work_item.milestone_id = milestone.id if milestone.present?
          # todo system notes for removed/not copied milestone?
        end

        def post_move_cleanup
          # do it
        end

        private

        def matching_milestone(title)
          return if title.blank?

          params = { title: title, project_ids: project&.id, group_ids: group&.self_and_ancestors&.pluck(:id) }

          milestones = MilestonesFinder.new(params).execute
          milestones.first
        end
      end
    end
  end
end
