# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class Labels < Base
        def before_create
          target_work_item.label_ids = cloneable_labels.pluck_primary_key
          # todo system notes for removed/not copied labels either here or in the after_create_copy?
        end

        def post_move_cleanup
          # do it
        end

        private

        def cloneable_labels
          params = {
            project_id: project&.id,
            group_id: group&.id,
            title: work_item.labels.select(:title),
            include_ancestor_groups: true
          }

          params[:only_group_labels] = true if target_parent.is_a?(Group)

          LabelsFinder.new(current_user, params).execute
        end
      end
    end
  end
end
