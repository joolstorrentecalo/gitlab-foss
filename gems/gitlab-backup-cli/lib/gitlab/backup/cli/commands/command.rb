# frozen_string_literal: true

module Gitlab
  module Backup
    module Cli
      module Commands
        class Command < Thor
          def self.exit_on_failure? = true

          class_option :backup_bucket,
            desc: "When backing up object storage, this is the bucket to backup to",
            required: false

          class_option :wait_for_completion,
            desc: "Wait for object storage backups to complete",
            type: :boolean,
            default: true

          class_option :registry_bucket,
            desc: "When backing up registry from object storage, this is the source bucket",
            required: false

          class_option :service_account_file,
            desc: "JSON file containing the Google service account credentials",
            default: "/etc/gitlab/backup-account-credentials.json"

          # Define the command basename instead of relying on $PROGRAM_NAME
          # This ensures the output is the same even inside RSpec
          def self.basename = 'gitlab-backup-cli'
        end
      end
    end
  end
end
