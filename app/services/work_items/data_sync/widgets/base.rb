# frozen_string_literal: true

module WorkItems
  module DataSync
    module Widgets
      class Base < ::WorkItems::Callbacks::Base
        attr_reader :work_item, :target_work_item, :current_user

        def initialize(work_item:, target_work_item:, widget:, current_user:, params: {})
          @work_item = work_item
          @target_work_item = target_work_item
          @widget = widget
          @current_user = current_user
          @params = params
        end

        # IMPORTANT: This is a callback that is called by `WorkItems::CreateService` before the work item is created.
        #
        # Has to be implemented in the specific widget class or it can be an empty implementation if the widget
        # does not need set any data before work item create
        def before_create; end

        # IMPORTANT: This is a callback that is called by `WorkItems::CreateService` after the work item is saved.
        #
        # Has to be implemented in the specific widget class or it can be an empty implementation if it does not copy
        # any data after work item is created
        def after_save_commit; end

        # IMPORTANT: This is a callback that is called by `BaseCleanupDataService` from `DataSync::MoveService` after
        # the work item is moved to the target namespace to delete the original work item data. That is because we have
        # to implement `MoveService` as `copy` to destination & `delete` from source.
        #
        # Has to be implemented in the specific widget class or it can be an empty implementation if it does not need to
        # cleanup any data on the original work item
        def post_move_cleanup; end

        private

        def target_parent
          work_item.project || work_item.group
        end

        def project
          target_parent if target_parent.is_a?(Project)
        end

        def group
          if target_parent.is_a?(Group)
            target_parent
          elsif target_parent&.group && current_user.can?(:read_group, target_parent.group)
            target_parent.group
          end
        end

        def log_error(message)
          Gitlab::AppLogger.error message
        end
      end
    end
  end
end
