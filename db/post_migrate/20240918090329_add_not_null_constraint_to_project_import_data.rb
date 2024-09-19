# frozen_string_literal: true

class AddNotNullConstraintToProjectImportData < Gitlab::Database::Migration[2.2]
  milestone '17.4'

  disable_ddl_transaction!

  def up
    add_not_null_constraint :project_import_data, :project_id
  end

  def down
    remove_not_null_constraint :project_import_data, :project_id
  end
end
