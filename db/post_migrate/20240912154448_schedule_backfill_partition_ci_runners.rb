# frozen_string_literal: true

class ScheduleBackfillPartitionCiRunners < Gitlab::Database::Migration[2.2]
  include Gitlab::Database::PartitioningMigrationHelpers

  milestone '17.5'

  disable_ddl_transaction!

  restrict_gitlab_migration gitlab_schema: :gitlab_ci

  def up
    enqueue_partitioning_data_migration :ci_runners, partitioned_table_name: :p_ci_runners
  end

  def down
    cleanup_partitioning_data_migration :ci_runners, partitioned_table_name: :p_ci_runners
  end
end
