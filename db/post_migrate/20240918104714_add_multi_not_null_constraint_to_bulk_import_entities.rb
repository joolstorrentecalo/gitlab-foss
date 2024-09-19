# frozen_string_literal: true

class AddMultiNotNullConstraintToBulkImportEntities < Gitlab::Database::Migration[2.2]
  disable_ddl_transaction!
  milestone '17.4'

  def up
    add_multi_column_not_null_constraint(:bulk_import_entities, :namespace_id, :project_id)
  end

  def down
    remove_multi_column_not_null_constraint(:bulk_import_entities, :namespace_id, :project_id)
  end
end
