# frozen_string_literal: true

module Types
  module Providers
    # rubocop:disable Graphql/AuthorizeTypes -- authorization happens in the providers
    class ClientLicensedFeaturesType < BaseObject
      graphql_name 'ClientLicensedFeatures'

      ::Providers::LicensedFeatureProvider.provided_fields.each do |key, value|
        field key, GraphQL::Types::Boolean, null: true,
          description: "Path for #{key}.", alpha: { milestone: value[:milestone] }
      end
    end
    # rubocop:enable Graphql/AuthorizeTypes
  end
end
