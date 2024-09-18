# frozen_string_literal: true

module Mutations
  module WorkItems
    class Move < BaseMutation
      graphql_name 'WorkItemMove'

      include Mutations::ResolvesNamespace

      argument :target_namespace_full_path, # rubocop:disable Graphql/IDType -- this is a string that can resolve to Group or Project
        GraphQL::Types::ID,
        required: true,
        description: 'Project or Group to move the work item to. For now this mutation only moves work ' \
          'items from Project to Project or from Group to Group'

      argument :work_item_id, ::Types::GlobalIDType[::WorkItem],
        required: true,
        description: 'Work item to move.'

      def resolve(work_item_id:, target_namespace_full_path:)
        work_item = authorized_find!(id: work_item_id)
        target_namespace = resolve_namespace(full_path: target_namespace_full_path).sync

        begin
          moved_work_item = ::WorkItems::DataSync::MoveService.new(
            work_item: work_item,
            target_namespace: target_namespace,
            current_user: current_user
          ).execute
        rescue ::WorkItems::DataSync::MoveService::MoveError => e
          errors = e.message
        end

        {
          issue: moved_work_item,
          errors: Array.wrap(errors)
        }
      end
    end
  end
end
