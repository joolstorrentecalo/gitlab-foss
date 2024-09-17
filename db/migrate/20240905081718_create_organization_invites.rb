# frozen_string_literal: true

class CreateOrganizationInvites < Gitlab::Database::Migration[2.2]
  enable_lock_retries!
  milestone '17.4'

  def change
    create_table :organization_invites, id: false do |t|
      t.references :organization, primary_key: true, foreign_key: { on_delete: :cascade }
      t.references :inviter_user, foreign_key: { to_table: :users, on_delete: :nullify }
      t.timestamps_with_timezone null: false
      t.datetime_with_timezone :accepted_at
      t.integer :access_level, default: 0, limit: 2, null: false
      t.text :email, null: false
      t.text :token, null: false
    end
  end
end
