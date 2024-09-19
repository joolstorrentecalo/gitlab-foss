# frozen_string_literal: true

class AddDesiredConfigGeneratorVersionToWorkspaces < Gitlab::Database::Migration[2.2]
  milestone '17.5'

  def change
    add_column :workspaces, :desired_config_generator_version, :integer, default: 3, null: false
  end
end
