# frozen_string_literal: true

class AddIndexOnProjectIdStatusToPackagesNugetSymbols < Gitlab::Database::Migration[2.2]
  disable_ddl_transaction!
  milestone '17.5'

  INDEX_NAME = :index_packages_nuget_symbols_on_project_id_status

  def up
    add_concurrent_index :packages_nuget_symbols, [:project_id, :status], name: INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :packages_nuget_symbols, INDEX_NAME
  end
end
