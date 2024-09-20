# frozen_string_literal: true

class CreatePCiRunners < Gitlab::Database::Migration[2.2]
  include Gitlab::Database::PartitioningMigrationHelpers::TableManagementHelpers

  milestone '17.5'
  disable_ddl_transaction!

  TABLE_NAME = 'ci_runners'
  PARTITIONED_TABLE_NAME = 'p_ci_runners'
  PARTITIONED_TABLE_PK = %w[runner_type id]

  def up
    partition_table_by_list(
      TABLE_NAME, 'runner_type', primary_key: PARTITIONED_TABLE_PK,
      partitioned_table_name: PARTITIONED_TABLE_NAME,
      partition_mappings: { instance_type: 1, group_type: 2, project_type: 3 },
      partition_name_format: 'p_%{partition_name}_ci_runners',
      create_partitioned_table_fn: -> { create_partitioned_table }
    )
  end

  def down
    drop_partitioned_table_for(TABLE_NAME, partitioned_table_name: PARTITIONED_TABLE_NAME)
  end

  private

  def create_partitioned_table
    options = 'PARTITION BY LIST (runner_type)'
    # rubocop: disable Migration/EnsureFactoryForTable -- we'll reuse the ci_runners factory once migrated
    create_table PARTITIONED_TABLE_NAME, primary_key: PARTITIONED_TABLE_PK, options: options do |t|
      t.bigint :id, null: false
      t.bigint :creator_id
      t.bigint :namespace_id, null: true
      t.bigint :project_id, null: true
      t.timestamps_with_timezone null: true
      t.datetime_with_timezone :contacted_at
      t.datetime_with_timezone :token_expires_at
      t.float :public_projects_minutes_cost_factor, null: false, default: 1.0
      t.float :private_projects_minutes_cost_factor, null: false, default: 1.0
      t.integer :access_level, null: false, default: 0
      t.integer :maximum_timeout
      t.integer :runner_type, null: false, limit: 2
      t.integer :registration_type, null: false, limit: 2, default: 0
      t.integer :creation_state, null: false, limit: 2, default: 0
      t.boolean :active, null: false, default: true
      t.boolean :run_untagged, null: false, default: true
      t.boolean :locked, null: false, default: false
      t.text :name, limit: 256
      t.text :token_encrypted, limit: 69
      t.text :token, limit: 128
      t.text :description, limit: 1024
      t.text :maintainer_note, limit: 1024
      t.text :allowed_plans, array: true, null: false, default: []
      t.bigint :allowed_plan_ids, array: true, null: false, default: []

      t.index [:token_encrypted, :runner_type], name: :index_uniq_p_ci_runners_on_token_encrypted, unique: true
      t.index [:token, :runner_type], name: :index_uniq_p_ci_runners_on_token, unique: true
      t.index :creator_id, name: :index_p_ci_runners_on_creator_id_where_creator_id_not_null,
        where: 'creator_id IS NOT NULL'
      t.index :namespace_id, name: :index_p_ci_runners_on_namespace_id_where_not_null,
        where: 'namespace_id IS NOT NULL'
      t.index :project_id, name: :index_p_ci_runners_on_project_id_where_not_null, where: 'project_id IS NOT NULL'
      t.index %i[active id], name: :index_p_ci_runners_on_active_and_id
      t.index %i[contacted_at id], name: :index_p_ci_runners_on_contacted_at_and_id_desc,
        order: { runner_type: :asc, id: :desc }
      t.index %i[contacted_at id], name: :index_p_ci_runners_on_contacted_at_and_id_where_inactive,
        order: { contacted_at: :desc, runner_type: :asc, id: :desc }, where: 'active = false'
      t.index %i[contacted_at id], name: :index_p_ci_runners_on_contacted_at_desc_and_id_desc,
        order: { contacted_at: :desc, runner_type: :asc, id: :desc }
      t.index %i[created_at id], name: :index_p_ci_runners_on_created_at_and_id_desc,
        order: { runner_type: :asc, id: :desc }
      t.index %i[created_at id], name: :index_p_ci_runners_on_created_at_and_id_where_inactive,
        order: { created_at: :desc, runner_type: :asc, id: :desc }, where: 'active = false'
      t.index %i[created_at id], name: :index_p_ci_runners_on_created_at_desc_and_id_desc,
        order: { created_at: :desc, runner_type: :asc, id: :desc }
      t.index :description, name: :index_p_ci_runners_on_description_trigram, using: :gin, opclass: :gin_trgm_ops
      t.index :locked, name: :index_p_ci_runners_on_locked
      t.index %i[token_expires_at id], name: :index_p_ci_runners_on_token_expires_at_and_id_desc,
        order: { runner_type: :asc, id: :desc }
      t.index %i[token_expires_at id], name: :index_p_ci_runners_on_token_expires_at_desc_and_id_desc,
        order: { token_expires_at: :desc, runner_type: :asc, id: :desc }
    end
    # rubocop: enable Migration/EnsureFactoryForTable
  end
end
