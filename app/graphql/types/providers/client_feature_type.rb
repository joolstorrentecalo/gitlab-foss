# frozen_string_literal: true

module Types
  module Providers
    # rubocop:disable Graphql/AuthorizeTypes -- authorization happens in the providers
    class ClientFeatureType < BaseObject
      graphql_name 'ClientFeature'

      field :enabled, GraphQL::Types::Boolean, null: false, description: 'Indicates if the feature is enabled.'
      field :name, GraphQL::Types::String, null: false, description: 'Identifier of the feature.'
    end
    # rubocop:enable Graphql/AuthorizeTypes
  end
end
