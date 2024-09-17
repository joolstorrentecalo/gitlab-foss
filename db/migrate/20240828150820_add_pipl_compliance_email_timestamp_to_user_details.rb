# frozen_string_literal: true

class AddPiplComplianceEmailTimestampToUserDetails < Gitlab::Database::Migration[2.2]
  milestone '17.5'

  def change
    add_column :user_details, :pipl_compliance_initial_email_sent_at, :datetime_with_timezone
  end
end
