# frozen_string_literal: true

class AddIndexOnStatusAndNextDeleteAttemptAtForContainerRepositories < Gitlab::Database::Migration[2.2]
  disable_ddl_transaction!

  milestone '17.5'

  def up
    add_concurrent_index :container_repositories,
      :next_delete_attempt_at,
      name: :container_repositories_next_delete_attempt_at,
      where: 'status = 0' # status: :delete_scheduled
  end

  def down
    remove_concurrent_index :container_repositories,
      :next_delete_attempt_at,
      name: :container_repositories_next_delete_attempt_at
  end
end
