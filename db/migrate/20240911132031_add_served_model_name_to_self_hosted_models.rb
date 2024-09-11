# frozen_string_literal: true

class AddServedModelNameToSelfHostedModels < Gitlab::Database::Migration[2.2]
  disable_ddl_transaction!

  milestone '17.5'

  def up
    with_lock_retries do
      add_column :ai_self_hosted_models, :served_model_name, :text
    end

    add_text_limit :ai_self_hosted_models, :served_model_name, 255
  end

  def down
    remove_column :ai_self_hosted_models, :served_model_name, if_exists: true
  end
end
