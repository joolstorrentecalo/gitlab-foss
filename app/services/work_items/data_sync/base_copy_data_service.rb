# frozen_string_literal: true

module WorkItems
  module DataSync
    class BaseCopyDataService < BaseService
      attr_reader :target_work_item_type, :create_params

      # rubocop:disable Layout/LineLength -- Keyword arguments are making the line a bit longer
      def initialize(work_item:, target_namespace:, target_work_item_type:, current_user: nil, params: {}, overwritten_params: {})
        super(work_item: work_item, target_namespace: target_namespace, current_user: current_user, params: params)

        @target_work_item_type = target_work_item_type
        @create_params = {
          id: nil,
          iid: nil,
          title: work_item.title,
          work_item_type: target_work_item_type,
          relative_position: relative_position,
          author: work_item.author,
          project_id: project&.id,
          namespace_id: target_namespace.id,
          imported_from: :none
          # moved_to_id
        }.merge(overwritten_params)
      end
      # rubocop:enable Layout/LineLength

      def execute
        # create the new work item
        create_work_item(create_params)
      end

      private

      def create_work_item(params)
        # This is a altered version of the WorkItem::CreateService. This alters the callbacks used by the
        # WorkItem::CreateService to setup data to be copied from the original work item before work item is created
        create_result = ::WorkItems::DataSync::BaseCreateService.new(
          original_work_item: work_item,
          container: target_namespace,
          current_user: current_user,
          params: params
        ).execute(skip_system_notes: true)

        new_work_item = create_result[:work_item]

        raise MoveError, create_result.errors.join(', ') if create_result.error? && new_work_item.blank?

        new_work_item
      end

      def relative_position
        return if work_item.namespace.root_ancestor.id != target_namespace.root_ancestor.id

        work_item.relative_position
      end
    end
  end
end
