# frozen_string_literal: true

class AddImagePullSecretsToWorkspacesConfig < Gitlab::Database::Migration[2.2]
  milestone '17.4'

  def change
    add_column :workspaces_agent_configs, :image_pull_secrets, :jsonb, default: []
  end
end
