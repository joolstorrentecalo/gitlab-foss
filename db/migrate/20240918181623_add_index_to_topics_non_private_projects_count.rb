# frozen_string_literal: true

class AddIndexToTopicsNonPrivateProjectsCount < Gitlab::Database::Migration[2.2]
  milestone '17.5'

  disable_ddl_transaction!

  TABLE = :topics
  INDEX = 'index_topics_on_non_private_projects_count_and_organization_id'

  def up
    add_concurrent_index(
      TABLE,
      %i[non_private_projects_count organization_id],
      order: { non_private_projects_count: :desc },
      name: INDEX
    )
  end

  def down
    remove_concurrent_index_by_name TABLE, INDEX
  end
end
