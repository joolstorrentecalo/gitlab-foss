# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes -- Authorization is done through the field
    class PipelineCreation < BaseObject
      graphql_name 'CiPipelineCreationType'

      field :in_progress,
        GraphQL::Types::Boolean,
        null: true,
        description: 'Whether a pipeline creation is in progress.',
        alpha: { milestone: '17.4' }
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
