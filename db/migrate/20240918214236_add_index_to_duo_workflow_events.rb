# frozen_string_literal: true

class AddIndexToDuoWorkflowEvents < Gitlab::Database::Migration[2.2]
  milestone '17.5'
  disable_ddl_transaction!

  WORKFLOW_INDEX_NAME = 'index_duo_workflows_events_on_workflow_id'

  def up
    add_concurrent_index :duo_workflows_events, :workflow_id, name: WORKFLOW_INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :duo_workflows_events, WORKFLOW_INDEX_NAME
  end
end
