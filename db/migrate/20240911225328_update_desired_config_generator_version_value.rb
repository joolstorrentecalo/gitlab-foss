# frozen_string_literal: true

class UpdateDesiredConfigGeneratorVersionValue < Gitlab::Database::Migration[2.2]
  BATCH_SIZE = 500

  milestone '17.5'
  disable_ddl_transaction!

  restrict_gitlab_migration gitlab_schema: :gitlab_main

  def up
    each_batch_range('workspaces', scope: ->(table) { table.all }, of: BATCH_SIZE) do |min, max|
      execute <<~SQL
        UPDATE workspaces
        SET desired_config_generator_version = config_version
        WHERE workspaces.id BETWEEN #{min} AND #{max}
      SQL
    end
  end

  def down
    # The desired_config_generator_version field is reverted back to its default value.
    each_batch_range('workspaces', scope: ->(table) { table.all }, of: BATCH_SIZE) do |min, max|
      execute <<~SQL
        UPDATE workspaces
        SET desired_config_generator_version = 3
        WHERE workspaces.id BETWEEN #{min} AND #{max}
      SQL
    end
  end
end
