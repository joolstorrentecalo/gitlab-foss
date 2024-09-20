# frozen_string_literal: true

module Gitlab
  module Backup
    module Cli
      module Targets
        # Abstract class used to implement a Backup Target
        class Target
          # dump task backup to `path`
          #
          # @param [String] path fully qualified backup task destination
          # @param [String] backup_id unique identifier for the backup
          def dump(path, backup_id)
            raise NotImplementedError
          end

          # restore task backup from `path`
          def restore(path, backup_id)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
