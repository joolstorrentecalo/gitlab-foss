# frozen_string_literal: true

class AddCorrectIdToWorkItemTypes < Gitlab::Database::Migration[2.2]
  milestone '17.5'

  def change
    add_column :work_item_types, :correct_id, :bigint
  end
end
