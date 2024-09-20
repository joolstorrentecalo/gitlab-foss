# frozen_string_literal: true

class AddColumnsToComplianceRequirements < Gitlab::Database::Migration[2.2]
  milestone '17.5'

  def change
    add_column :compliance_requirements, :requirement_type, :smallint, null: false # rubocop:disable Rails/NotNullColumn -- table is empty
    add_column :compliance_requirements, :expression, :jsonb, default: {}
  end
end
