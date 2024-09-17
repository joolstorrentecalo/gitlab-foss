# frozen_string_literal: true

class AddMemberRoleIdToProjectAuthorizations < Gitlab::Database::Migration[2.2]
  milestone '17.5'
  disable_ddl_transaction!

  def up
    with_lock_retries do
      add_column :project_authorizations, :member_role_id, :bigint
    end
  end

  def down
    with_lock_retries do
      remove_column :project_authorizations, :member_role_id
    end
  end
end
