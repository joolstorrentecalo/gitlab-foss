# frozen_string_literal: true

class CreatePersonalAccessTokenAdvancedScopes < Gitlab::Database::Migration[2.2]
  INDEX_NAME_ORG = 'index_pat_advanced_scopes_on_organization_id'
  disable_ddl_transaction!
  milestone '17.5'

  def up
    unless table_exists?(:personal_access_token_advanced_scopes)
      create_table :personal_access_token_advanced_scopes do |t|
        t.timestamps_with_timezone null: false
        t.text :http_methods, array: true, default: [], null: false
        t.text :path_string, null: false, limit: 4096
        t.bigint :organization_id, null: false
      end
    end

    add_index :personal_access_token_advanced_scopes, :organization_id, name: INDEX_NAME_ORG
    add_concurrent_foreign_key :personal_access_token_advanced_scopes, :organizations, column: :organization_id,
      on_delete: :cascade

    return if column_exists?(:personal_access_token_advanced_scopes, :personal_access_token_id)

    # rubocop:disable Rails/NotNullColumn -- table is empty
    add_reference :personal_access_token_advanced_scopes, :personal_access_token, foreign_key: { on_delete: :cascade },
      index: { name: 'index_pat_advanced_scopes_on_pat_id' }, null: false
    # rubocop:enable Rails/NotNullColumn
  end

  def down
    if index_exists?(:personal_access_token_advanced_scopes, :personal_access_token_id,
      name: 'index_pat_advanced_scopes_on_pat_id')
      remove_concurrent_index :personal_access_token_advanced_scopes, :personal_access_token_id,
        name: 'index_pat_advanced_scopes_on_pat_id'
    end

    if foreign_key_exists?(:personal_access_token_advanced_scopes, column: :organization_id)
      remove_foreign_key :personal_access_token_advanced_scopes, column: :organization_id
    end

    if foreign_key_exists?(:personal_access_token_advanced_scopes, :personal_access_token_id)
      remove_foreign_key :personal_access_token_advanced_scopes, :personal_access_token
    end

    if index_exists?(:personal_access_token_advanced_scopes, :personal_access_token_id,
      name: 'index_pat_advanced_scopes_on_pat_id')
      remove_concurrent_index :personal_access_token_advanced_scopes, :personal_access_token_id,
        name: 'index_pat_advanced_scopes_on_pat_id'
    end

    return unless table_exists?(:personal_access_token_advanced_scopes)

    drop_table :personal_access_token_advanced_scopes
  end
end
