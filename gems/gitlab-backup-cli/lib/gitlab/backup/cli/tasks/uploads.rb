# frozen_string_literal: true

module Gitlab
  module Backup
    module Cli
      module Tasks
        class Uploads < Task
          def self.id = 'uploads'

          def human_name = _('uploads')

          def destination_path = 'uploads.tar.gz'

          private

          def target
            check_object_storage(
              Gitlab::Backup::Cli::Targets::Files.new(
                storage_path, excludes: ['tmp']
              )
            )
          end

          def storage_path = context.upload_path
        end
      end
    end
  end
end
