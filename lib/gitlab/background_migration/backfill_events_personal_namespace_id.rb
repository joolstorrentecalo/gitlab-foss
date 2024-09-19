# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class BackfillEventsPersonalNamespaceId < BatchedMigrationJob
      feature_category :database
      operation_name :backfill_personal_namespace_id

      scope_to ->(relation) { relation.where(project_id: nil) }

      def perform
        each_sub_batch do |sub_batch|
          without_sharding_key_value = sub_batch.where(group_id: nil, personal_namespace_id: nil)

          connection.execute(
            <<~SQL
              UPDATE events
              SET personal_namespace_id = users.namespace_id
              FROM users
              WHERE events.author_id = users.id
              AND events.id IN (#{without_sharding_key_value.select(:id).to_sql})
            SQL
          )
        end
      end
    end
  end
end
