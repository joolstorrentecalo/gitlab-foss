# frozen_string_literal: true

class DeleteImportFailuresWithoutProjectIdOrGroupId < Gitlab::Database::Migration[2.2]
  milestone '17.4'

  restrict_gitlab_migration gitlab_schema: :gitlab_main

  def up
    execute("DELETE FROM import_failures WHERE project_id IS NULL AND group_id IS NULL")
  end

  def down
    # no-op
  end
end
