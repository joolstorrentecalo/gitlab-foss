# frozen_string_literal: true

module Types
  module Providers
    # rubocop:disable Graphql/AuthorizeTypes -- authorization happens in the providers
    class ClientPermissionsType < BaseObject
      graphql_name 'ClientPermissions'

      ::Providers::PermissionProvider.provided_fields.each do |key, value|
        field key, GraphQL::Types::String, null: true,
          description: "Path for #{key}.", alpha: { milestone: value[:milestone] }
      end
    end
    # rubocop:enable Graphql/AuthorizeTypes
  end
end
