# frozen_string_literal: true

module Resolvers
  module Providers
    class ClientProviderResolver < BaseResolver
      type Types::Providers::ClientProviderType.connection_type, null: true

      argument :full_path, GraphQL::Types::ID,
        required: false,
        description: "Full path of the Namespace. For example, `gitlab-org/gitlab-foss`."

      def resolve(**args)
        group = Group.find_by_full_path(args[:full_path]) if args[:full_path]
        project = Project.find_by_full_path(args[:full_path]) if group.nil?

        { group: group || project&.group, project: project }
      end
    end
  end
end
