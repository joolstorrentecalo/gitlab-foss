# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class BranchType < BaseObject
    graphql_name 'Branch'

    field :name,
      GraphQL::Types::String,
      null: false,
      description: 'Name of the branch.'

    field :commit, Types::CommitType,
      null: true, resolver: Resolvers::BranchCommitResolver,
      description: 'Commit for the branch.'

    field :link, GraphQL::Types::String, null: true, description: 'URL of branch.'
  end
  # rubocop: enable Graphql/AuthorizeTypes
end
