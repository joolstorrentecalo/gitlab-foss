# frozen_string_literal: true

module Types
  module WorkItems
    module Widgets
      # Disabling widget level authorization as it might be too granular
      # and we already authorize the parent work item
      # rubocop:disable Graphql/AuthorizeTypes -- reason above
      class DevelopmentType < BaseObject
        graphql_name 'WorkItemWidgetDevelopment'
        description 'Represents a development widget'
        include Gitlab::Routing.url_helpers

        implements Types::WorkItems::WidgetInterface

        field :branches,
          Types::BranchType.connection_type,
          null: true,
          calls_gitaly: true,
          description:
          'Branches associated with work item.'
        field :closing_merge_requests,
          Types::WorkItems::ClosingMergeRequestType.connection_type,
          null: true,
          description: 'Merge requests that will close the work item when merged.'
        field :will_auto_close_by_merge_request,
          GraphQL::Types::Boolean,
          null: false,
          description: 'Whether the work item will automatically be closed when a closing merge request is merged.'

        def branches
          return [] unless object.work_item.project

          ::Issues::RelatedBranchesService
            .new(container: object.work_item.project, current_user: current_user)
            .execute(object.work_item)
            .map { |branch| branch.merge(link: branch_link(branch)) }
        end

        def closing_merge_requests
          if object.closing_merge_requests.loaded?
            object.closing_merge_requests
          else
            object.closing_merge_requests.preload_merge_request_for_authorization
          end
        end

        def branch_link(branch)
          project_compare_path(
            object.work_item.project,
            from: object.work_item.project.default_branch,
            to: branch[:name]
          )
        end
      end
      # rubocop:enable Graphql/AuthorizeTypes
    end
  end
end

Types::WorkItems::Widgets::DevelopmentType.prepend_mod
