# frozen_string_literal: true

module Gitlab
  module Backup
    module Cli
      module Tasks
        class TerraformState < Task
          def self.id = 'terraform_state'

          def human_name = _('terraform states')

          def destination_path = 'terraform_state.tar.gz'

          private

          def target
            check_object_storage(
              Gitlab::Backup::Cli::Targets::Files.new(
                storage_path, excludes: ['tmp']
              )
            )
          end

          def storage_path = context.terraform_state_path
        end
      end
    end
  end
end
