# frozen_string_literal: true

module Gitlab
  module BitbucketServerImport
    module Importers
      class PullRequestImporter
        include Loggable

        def initialize(project, hash)
          @project = project
          @formatter = Gitlab::ImportFormatter.new
          @user_finder = UserFinder.new(project)
          @mentions_converter = Gitlab::Import::MentionsConverter.new('bitbucket_server', project)

          # Object should behave as a object so we can remove object.is_a?(Hash) check
          # This will be fixed in https://gitlab.com/gitlab-org/gitlab/-/issues/412328
          @object = hash.with_indifferent_access
          @original_users_map = {}.compare_by_identity
        end

        def execute
          log_info(import_stage: 'import_pull_request', message: 'starting', iid: object[:iid])

          attributes = {
            iid: object[:iid],
            title: object[:title],
            description: description,
            reviewer_ids: reviewers,
            source_project_id: project.id,
            source_branch: Gitlab::Git.ref_name(object[:source_branch_name]),
            source_branch_sha: source_branch_sha,
            target_project_id: project.id,
            target_branch: Gitlab::Git.ref_name(object[:target_branch_name]),
            target_branch_sha: object[:target_branch_sha],
            state_id: MergeRequest.available_states[object[:state]],
            author_id: author_id(object),
            created_at: object[:created_at],
            updated_at: object[:updated_at],
            imported_from: ::Import::HasImportSource::IMPORT_SOURCES[:bitbucket_server]
          }

          creator = Gitlab::Import::MergeRequestCreator.new(project)

          merge_request = creator.execute(attributes)

          # Create refs/merge-requests/iid/head reference for the merge request
          merge_request.fetch_ref!

          push_placeholder_references(merge_request) if merge_request.persisted?

          log_info(import_stage: 'import_pull_request', message: 'finished', iid: object[:iid])
        end

        private

        attr_reader :object, :project, :formatter, :user_finder, :mentions_converter

        def description
          description = ''
          description += author_line
          description += object[:description] if object[:description]

          if Feature.enabled?(:bitbucket_server_convert_mentions_to_users, project.creator)
            description = mentions_converter.convert(description)
          end

          description
        end

        def author_line
          return '' if user_finder.uid(object)

          formatter.author_line(object[:author])
        end

        def author_id(object)
          user_finder.author_id(object)
        end

        def reviewers
          return [] unless object[:reviewers].present?

          object[:reviewers].filter_map do |reviewer|
            if placeholder_user_mapping_enabled?
              user_finder.placeholder_user_id(reviewer)
            elsif Feature.enabled?(:bitbucket_server_user_mapping_by_username, project, type: :ops)
              user_finder.find_user_id(by: :username, value: reviewer.dig('user', 'slug'))
            else
              user_finder.find_user_id(by: :email, value: reviewer.dig('user', 'emailAddress'))
            end
          end
        end

        def placeholder_user_mapping_enabled?
          Feature.enabled?(:importer_user_mapping, project.creator) &&
            Feature.enabled?(:bitbucket_server_user_mapping, project.creator)
        end

        def source_branch_sha
          source_branch_sha = project.repository.commit(object[:source_branch_sha])&.sha

          return source_branch_sha if source_branch_sha

          project.repository.find_commits_by_message(object[:source_branch_sha])&.first&.sha
        end

        def push_placeholder_references(merge_request)
          return unless placeholder_user_mapping_enabled?

          push_merge_request_reference(merge_request)
          push_reviewer_references(merge_request)
        end

        def push_merge_request_reference(merge_request)
          source_user = user_finder.source_user(object[:author_email])

          return if source_user.accepted_status? &&
            merge_request.author_id == source_user.reassign_to_user_id

          ::Import::PlaceholderReferences::PushService.from_record(
            import_source: ::Import::SOURCE_BITBUCKET_SERVER,
            import_uid: project.import_state.id,
            record: merge_request,
            source_user: source_user,
            user_reference_column: :author_id
          ).execute
        end

        def push_reviewer_references(merge_request)
          mr_reviewers = merge_request.merge_request_reviewers
          source_users = ::Import::SourceUser.for_placeholders(mr_reviewers.collect(&:user_id))

          return unless mr_reviewers.any?
          return unless source_users.any?

          mr_reviewers.each do |mr_reviewer|
            source_user = source_users.find { |user| user.placeholder_user_id == mr_reviewer.user_id }

            next unless source_user.present?
            next if source_user.accepted_status? && mr_reviewer.user_id == source_user.reassign_to_user_id

            ::Import::PlaceholderReferences::PushService.from_record(
              import_source: ::Import::SOURCE_BITBUCKET_SERVER,
              import_uid: project.import_state.id,
              record: mr_reviewer,
              source_user: source_user,
              user_reference_column: :user_id
            ).execute
          end
        end
      end
    end
  end
end
