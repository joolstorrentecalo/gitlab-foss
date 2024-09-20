# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/database/batched_background_migrations.html
# for more information on how to use batched background migrations

# Update below commented lines with appropriate values.

module Gitlab
  module BackgroundMigration
    class BackfillPersonalAccessTokenSevenDaysNotificationSent < BatchedMigrationJob
      # This is used as the key on collecting metrics
      operation_name :backfill_personal_access_token_seven_days_notification_sent

      # rubocop:disable CodeReuse/ActiveRecord -- guidelines says query methods are okay to use here
      scope_to ->(relation) do
        relation.where(expire_notification_delivered: true, seven_days_notification_sent_at: nil)
                .where.not(expires_at: nil)
      end
      # rubocop:enable CodeReuse/ActiveRecord

      feature_category :system_access

      def perform
        each_sub_batch do |sub_batch|
          sub_batch.update_all("seven_days_notification_sent_at = (expires_at - interval '7 days')")
        end
      end
    end
  end
end
