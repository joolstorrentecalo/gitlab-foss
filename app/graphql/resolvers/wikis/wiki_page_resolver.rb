# frozen_string_literal: true

module Resolvers
  module Wikis
    class WikiPageResolver < BaseResolver
      description 'Retrieve an wiki page'

      type Types::Wikis::WikiPageType, null: true

      argument :id, Types::GlobalIDType[WikiPage::Meta], required: true, description: 'ID of the wiki page.'

      def resolve(id:)
        ::WikiPage::Meta.find(extract_wiki_page_meta_id(id))
      end

      private

      def extract_wiki_page_meta_id(gid)
        GitlabSchema.parse_gid(gid, expected_type: ::WikiPage::Meta).model_id
      end
    end
  end
end
