# frozen_string_literal: true

require "google/cloud/storage_transfer"

module Gitlab
  module Backup
    module Cli
      module Targets
        class ObjectStorage
          class Google < Target
            OperationNotFoundError = Class.new(StandardError)

            attr_accessor :object_type, :backup_bucket, :client, :config, :operation

            def initialize(object_type, options, config)
              check_env
              @object_type = object_type
              @backup_bucket = options.remote_directory
              @config = config
              @client = ::Google::Cloud::StorageTransfer.storage_transfer_service
            end

            def dump(_, backup_id)
              @operation = "backup"
              response = find_or_create_job(backup_id)
              run_request = {
                project_id: backup_job_spec(backup_id)[:project_id],
                job_name: response.name
              }
              client.run_transfer_job run_request
            end

            def restore(_, backup_id)
              @operation = "restore"
              response = find_or_create_job(backup_id)
              run_request = {
                project_id: restore_job_spec(backup_id)[:project_id],
                job_name: response.name
              }
              client.run_transfer_job run_request
            end

            def job_name
              "transferJobs/#{object_type}-#{operation}"
            end

            def backup_job_spec(backup_id)
              job_spec(
                config.object_store.remote_directory, backup_bucket, destination_path: backup_path(backup_id)
              )
            end

            def restore_job_spec(backup_id)
              job_spec(
                backup_bucket, config.object_store.remote_directory, source_path: backup_path(backup_id)
              )
            end

            def backup_path(backup_id)
              "backups/#{backup_id}/#{object_type}/"
            end

            def find_job_spec(backup_id)
              case @operation
              when "backup"
                backup_job_spec(backup_id)
              when "restore"
                restore_job_spec(backup_id)
              else
                raise StandardError "Operation #{@operation} not found"
              end
            end

            def job_spec(source, destination, source_path: nil, destination_path: nil)
              {
                project_id: config.object_store.connection.google_project,
                name: job_name,
                transfer_spec: {
                  gcs_data_source: {
                    bucket_name: source,
                    path: source_path
                  },
                  gcs_data_sink: {
                    bucket_name: destination,
                    # NOTE: The trailing '/' is required
                    path: destination_path
                  }
                },
                status: :ENABLED
              }
            end

            private

            def check_env
              # We expect service account credentials to be passed via env variables. If they are not, attempt
              # to use the local service account credentials and warn.
              return if ENV.key?("GOOGLE_CLOUD_CREDENTIALS") || ENV.key?("GOOGLE_APPLICATION_CREDENTIALS")

              log.warning("No credentials provided.")
              log.warning("If we're in GCP, we will attempt to use the machine service account.")
              log.warning("This is not recommended.")
            end

            def find_or_create_job(backup_id)
              begin
                response = client.get_transfer_job(
                  job_name: job_name, project_id: config.object_store.connection.google_project
                )
                log.info("Existing job for #{object_type} found, using")
                job_update = find_job_spec(backup_id)
                job_update.delete(:project_id)

                client.update_transfer_job(
                  job_name: job_name,
                  project_id: config.object_store.connection.google_project,
                  transfer_job: job_update
                )
              rescue ::Google::Cloud::NotFoundError
                log.info("Existing job for #{object_type} not found, creating one")
                response = client.create_transfer_job transfer_job: find_job_spec(backup_id)
              end
              response
            end

            def log
              Gitlab::Backup::Cli::Output
            end
          end
        end
      end
    end
  end
end
