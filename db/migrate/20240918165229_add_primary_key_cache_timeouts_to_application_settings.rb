# frozen_string_literal: true

class AddPrimaryKeyCacheTimeoutsToApplicationSettings < Gitlab::Database::Migration[2.2]
  milestone '17.5'

  def change
    add_column :application_settings, :primary_key_cache_timeouts, :jsonb, default: { namespaces: 60 }, null: false
  end
end
