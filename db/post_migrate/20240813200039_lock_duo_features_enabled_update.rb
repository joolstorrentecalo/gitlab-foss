# frozen_string_literal: true

class LockDuoFeaturesEnabledUpdate < Gitlab::Database::Migration[2.2]
  milestone '17.4'

  TABLE_NAME = namespace_settings
  INDEX_COLUMNS = %i[duo_features_enabled lock_duo_features_enabled]
  INDEX_NAME = :tmp_duo_features_enabled_index

  restrict_gitlab_migration gitlab_schema: :gitlab_main

  def up
    add_concurrent_index TABLE_NAME, INDEX_COLUMNS, name: INDEX_NAME
    NamespaceSetting.where(duo_features_enabled: true, lock_duo_features_enabled: true)
      .update_all(lock_duo_features_enabled: false)
    remove_concurrent_index TABLE_NAME, INDEX_COLUMNS, name: INDEX_NAME
  end

  def down
    # no-op. We can't update all records `where(duo_features_enabled: true, lock_duo_features_enabled: false)`
    # because some of them may have been pre-existing.
  end
end
