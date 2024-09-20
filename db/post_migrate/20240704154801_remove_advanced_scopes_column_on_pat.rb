# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class RemoveAdvancedScopesColumnOnPat < Gitlab::Database::Migration[2.2]
  disable_ddl_transaction!
  milestone '17.5'

  def up
    with_lock_retries do
      remove_column :personal_access_tokens, :advanced_scopes, if_exists: true
    end
  end

  def down
    add_column :personal_access_tokens, :advanced_scopes, :text, if_not_exists: true
    add_text_limit :personal_access_tokens, :advanced_scopes, 4096
  end
end
