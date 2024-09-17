# frozen_string_literal: true

module Gitlab
  module Backup
    module Cli
      class BaseExecutor
        attr_reader :backup_bucket, :wait_for_completion, :registry_bucket, :service_account_file

        CMD_OPTIONS = %w[backup_bucket wait_for_completion registry_bucket service_account_file].freeze

        def initialize(backup_options: {})
          @backup_bucket = backup_options["backup_bucket"]
          @registry_bucket = backup_options["registry_bucket"]
          @wait_for_completion = backup_options["wait_for_completion"]
          @service_account_file = backup_options["service_account_file"]
        end
      end
    end
  end
end
