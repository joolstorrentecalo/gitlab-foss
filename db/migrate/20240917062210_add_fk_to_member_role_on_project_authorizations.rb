# frozen_string_literal: true

class AddFkToMemberRoleOnProjectAuthorizations < Gitlab::Database::Migration[2.2]
  milestone '17.5'
  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :project_authorizations, :member_roles, column: :member_role_id, on_delete: :nullify
  end

  def down
    with_lock_retries do
      remove_foreign_key :project_authorizations, column: :member_role_id
    end
  end
end
