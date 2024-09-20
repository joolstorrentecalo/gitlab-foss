# frozen_string_literal: true

module Gitlab
  module Backup
    module Cli
      module Tasks
        class Registry < Task
          def self.id = 'registry'

          def enabled = Gitlab.config.registry.enabled

          def human_name = _('container registry images')

          def destination_path = 'registry.tar.gz'

          # TODO Pass container_registry_bucket to Tasks:Registry
          def object_storage?
            !container_registry_bucket.nil?
          end

          # Registry does not use consolidated object storage config.
          def config
            settings = {
              object_store: {
                connection: Gitlab::Backup::Cli::SourceContext.new.config('object_store').connection.to_hash,
                remote_directory: container_registry_bucket
              }
            }
            GitlabSettings::Options.build(settings)
          end

          private

          def target
            check_object_storage(Gitlab::Backup::Cli::Targets::Files.new(storage_path))
          end

          def storage_path = context.registry_path
        end
      end
    end
  end
end
