# frozen_string_literal: true

module Gitlab
  module BitbucketServerImport
    # Class that can be used for finding a GitLab user ID based on a BitBucket user

    class UserFinder
      attr_reader :project

      CACHE_KEY = 'bitbucket_server-importer/user-finder/%{project_id}/%{by}/%{value}'
      CACHE_USER_ID_NOT_FOUND = -1

      # project - An instance of `Project`
      def initialize(project)
        @project = project
      end

      def author_id(object)
        if placeholder_user_mapping_enabled?
          placeholder_user_id(object)
        else
          uid(object) || project.creator_id
        end
      end

      # Object should behave as a object so we can remove object.is_a?(Hash) check
      # This will be fixed in https://gitlab.com/gitlab-org/gitlab/-/issues/412328
      def uid(object)
        # We want this to only match either username or email depending on the flag state.
        # There should be no fall-through.
        if Feature.enabled?(:bitbucket_server_user_mapping_by_username, project, type: :ops)
          find_user_id(by: :username, value: object.is_a?(Hash) ? object[:author_username] : object.author_username)
        else
          find_user_id(by: :email, value: object.is_a?(Hash) ? object[:author_email] : object.author_email)
        end
      end

      def find_user_id(by:, value:)
        return unless value

        cache_key = build_cache_key(by, value)
        cached_id = cache.read_integer(cache_key)

        return if cached_id == CACHE_USER_ID_NOT_FOUND
        return cached_id if cached_id

        user = if by == :email
                 User.find_by_any_email(value, confirmed: true)
               else
                 User.find_by_username(value)
               end

        user&.id.tap do |id|
          cache.write(cache_key, id || CACHE_USER_ID_NOT_FOUND)
        end
      end

      def placeholder_user_id(object)
        source_user_mapper.find_or_create_source_user(
          source_name: object[:author],
          source_username: object[:author_username],
          source_user_identifier: object[:author_email]
        ).mapped_user_id
      end

      def source_user(identifier)
        source_user_mapper.find_source_user(identifier)
      end

      private

      def cache
        Cache::Import::Caching
      end

      def build_cache_key(by, value)
        format(CACHE_KEY, project_id: project.id, by: by, value: value)
      end

      def source_user_mapper
        @source_user_mapper ||= Gitlab::Import::SourceUserMapper.new(
          namespace: project.root_ancestor,
          import_type: ::Import::SOURCE_BITBUCKET_SERVER,
          source_hostname: project.import_data.credentials[:base_uri]
        )
      end

      def placeholder_user_mapping_enabled?
        Feature.enabled?(:importer_user_mapping, project.creator) &&
          Feature.enabled?(:bitbucket_server_user_mapping, project.creator)
      end
    end
  end
end
