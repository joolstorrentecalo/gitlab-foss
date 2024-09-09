# frozen_string_literal: true

class AddRoleApproversToApprovalMergeRequestRules < Gitlab::Database::Migration[2.2]
  milestone '17.4'
  enable_lock_retries!

  def up
    add_column :approval_merge_request_rules, :role_approvers, :integer, array: true, default: [], null: false
  end

  def down
    remove_column :approval_merge_request_rules, :role_approvers
  end
end
