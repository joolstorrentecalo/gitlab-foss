# frozen_string_literal: true

module Types
  module Providers
    # rubocop:disable Graphql/AuthorizeTypes -- authorization happens in the providers
    class ClientProviderType < Types::BaseObject
      graphql_name 'ClientProvider'
      description 'Provides data to vue applications to initialize with the right configuration.'

      field :is_signed_in, GraphQL::Types::Boolean,
        description: 'Indicates if the user is signed in.'

      field :features, [::Types::Providers::ClientFeatureType],
        description: 'feature flags.' do
        argument :names, [GraphQL::Types::String],
          required: true,
          description: 'feature flags to return.'
      end

      field :licensed_features, ::Types::Providers::ClientLicensedFeaturesType,
        description: 'feature flags.'

      field :paths, ::Types::Providers::ClientPathsType,
        description: 'paths.'

      field :permissions, ::Types::Providers::ClientPermissionsType,
        description: 'permission.'

      field :default_branch, GraphQL::Types::String,
        description: 'Default branch of the project.',
        null: true

      field :issue_initial_sort, GraphQL::Types::String,
        description: 'Default sort for issues.',
        null: true

      # rubocop: disable Naming/PredicateName -- we want to use the method as field
      def is_signed_in
        current_user.present?
      end
      # rubocop: enable Naming/PredicateName

      def default_branch
        object[:project]&.default_branch_or_main
      end

      def issue_initial_sort
        current_user&.user_preference&.issues_sort
      end

      def features(names:)
        provider = ::Providers::FeatureProvider.new(current_user: current_user, group: object[:group],
          project: object[:project])

        names.map do |name|
          {
            name: name,
            enabled: provider.enabled?(name.underscore)
          }
        end
      end

      def licensed_features
        ::Providers::LicensedFeatureProvider.new(current_user: current_user, group: object[:group],
          project: object[:project])
      end

      def permissions
        ::Providers::PermissionProvider.new(current_user: current_user, group: object[:group],
          project: object[:project])
      end

      def paths
        ::Providers::PathProvider.new(current_user: current_user, group: object[:group],
          project: object[:project])
      end
    end
    # rubocop:enable Graphql/AuthorizeTypes
  end
end
