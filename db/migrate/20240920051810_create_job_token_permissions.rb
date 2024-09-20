# frozen_string_literal: true

class CreateJobTokenPermissions < Gitlab::Database::Migration[2.2]
  milestone '17.5'

  enable_lock_retries!

  def change
    create_table :ci_job_token_permissions do |t|
      t.jsonb :permissions, default: [], null: false
    end
  end
end
