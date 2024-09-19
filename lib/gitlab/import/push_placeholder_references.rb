# frozen_string_literal: true

module Gitlab
  module Import
    class PushPlaceholderReferences
      def self.push_references(
        source_user_identifier:,
        namespace:,
        source_hostname:,
        import_type:,
        object:,
        user_reference:)

        source_user = Import::SourceUserMapper.new(
          namespace: namespace,
          source_hostname: source_hostname,
          import_type: import_type.to_s
        ).find_source_user(source_user_identifier)

        return if source_user.accepted_status?

        ::Import::PlaceholderReferences::PushService.from_record(
          import_source: import_type,
          import_uid: object.project.import_state.id,
          record: object,
          source_user: source_user,
          user_reference_column: user_reference
        ).execute
      end
    end
  end
end
