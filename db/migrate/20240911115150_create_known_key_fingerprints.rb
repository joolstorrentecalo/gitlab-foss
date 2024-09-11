# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateKnownKeyFingerprints < Gitlab::Database::Migration[2.2]
  # When using the methods "add_concurrent_index" or "remove_concurrent_index"
  # you must disable the use of transactions
  # as these methods can not run in an existing transaction.
  # When using "add_concurrent_index" or "remove_concurrent_index" methods make sure
  # that either of them is the _only_ method called in the migration,
  # any other changes should go in a separate migration.
  # This ensures that upon failure _only_ the index creation or removing fails
  # and can be retried or reverted easily.
  #
  # To disable transactions uncomment the following line and remove these
  # comments:
  # disable_ddl_transaction!
  milestone '17.4'

  # Add dependent 'batched_background_migrations.queued_migration_version' values.
  # DEPENDENT_BATCHED_BACKGROUND_MIGRATIONS = []

  def change
    create_table :known_key_fingerprints do |t| # rubocop: disable Migration/EnsureFactoryForTable -- Some reason
      t.text :fingerprint, limit: 255

      t.timestamps_with_timezone null: false
    end
  end
end
