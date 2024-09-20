# frozen_string_literal: true

module Gitlab
  module Backup
    module Cli
      module Targets
        class Files < Target
          DEFAULT_EXCLUDE = ['lost+found'].freeze

          # Use the content from stdin instead of an actual filepath (used by tar as input or output)
          USE_STDIN = '-'

          attr_reader :excludes, :workdir

          # @param [String] storage_path
          # @param [Array] excludes
          def initialize(storage_path, excludes: [])
            @storage_path = storage_path
            @excludes = excludes
          end

          def dump(backup_tarball, _)
            archive_file = [backup_tarball, 'w', 0o600]
            tar_command = Utils::Tar.new.pack_cmd(
              archive_file: USE_STDIN,
              target_directory: storage_realpath,
              target: '.',
              excludes: excludes)

            pipeline = Shell::Pipeline.new(tar_command, Gitlab::Backup::Cli.compression_command)
            result = pipeline.run!(output: archive_file)

            return if pipeline.success? || tar_ignore_non_success?(result.status_list[1].exitstatus, result.stderr)

            raise_custom_error(backup_tarball)
          end

          def restore(backup_tarball, workdir, _)
            backup_existing_files_dir(backup_tarball, workdir)

            archive_file = backup_tarball.to_s
            tar_command = Utils::Tar.new.extract_cmd(
              archive_file: USE_STDIN,
              target_directory: storage_realpath)

            pipeline = Shell::Pipeline.new(Gitlab::Backup::Cli.decompression_command, tar_command)
            result = pipeline.run!(input: archive_file)

            return true if pipeline.success? || tar_ignore_non_success?(result.status_list[1].exitstatus, result.stderr)

            raise Backup::Cli::Error, "Restore operation failed: #{result.stderr}"
          end

          def backup_existing_files_dir(backup_tarball, workdir)
            name = File.basename(backup_tarball, '.tar.gz')
            timestamped_files_path = workdir.join('tmp', "#{name}.#{Time.now.to_i}")

            return unless File.exist?(storage_realpath)

            # Move all files in the existing repos directory except . and .. to
            # repositories.<timestamp> directory
            FileUtils.mkdir_p(timestamped_files_path, mode: 0o700)

            dot_references = [File.join(storage_realpath, "."), File.join(storage_realpath, "..")]
            matching_files = Dir.glob(File.join(storage_realpath, "*"), File::FNM_DOTMATCH)
            files = matching_files - dot_references

            FileUtils.mv(files, timestamped_files_path)
          rescue Errno::EACCES
            access_denied_error(storage_realpath)
          rescue Errno::EBUSY
            resource_busy_error(storage_realpath)
          end

          def noncritical_warning?(warning)
            noncritical_warnings = [
              /^g?tar: \.: Cannot mkdir: No such file or directory$/
            ]

            noncritical_warnings.map { |w| warning =~ w }.any?
          end

          def tar_ignore_non_success?(exitstatus, output)
            # tar can exit with nonzero code:
            #  1 - if some files changed (i.e. a CI job is currently writes to log)
            #  2 - if it cannot create `.` directory (see issue https://gitlab.com/gitlab-org/gitlab/-/issues/22442)
            #  http://www.gnu.org/software/tar/manual/html_section/tar_19.html#Synopsis
            #  so check tar status 1 or stderr output against some non-critical warnings
            if exitstatus == 1
              Output.print_info "Ignoring tar exit status 1 'Some files differ': #{output}"
              return true
            end

            # allow tar to fail with other non-success status if output contain non-critical warning
            if noncritical_warning?(output)
              Output.print_info(
                "Ignoring non-success exit status #{exitstatus} due to output of non-critical warning(s): #{output}")
              return true
            end

            false
          end

          def raise_custom_error(backup_tarball)
            raise Errors::FileBackupError.new(storage_realpath, backup_tarball)
          end

          private

          def storage_realpath
            @storage_realpath ||= File.realpath(@storage_path)
          end

          def access_denied_error(path)
            message = <<~ERROR

            ### NOTICE ###
            As part of restore, the task tried to move existing content from #{path}.
            However, it seems that directory contains files/folders that are not owned
            by the user #{Gitlab.config.gitlab.user}. To proceed, please move the files
            or folders inside #{path} to a secure location so that #{path} is empty and
            run restore task again.

            ERROR
            raise message
          end

          def resource_busy_error(path)
            message = <<~ERROR

            ### NOTICE ###
            As part of restore, the task tried to rename `#{path}` before restoring.
            This could not be completed, perhaps `#{path}` is a mountpoint?

            To complete the restore, please move the contents of `#{path}` to a
            different location and run the restore task again.

            ERROR
            raise message
          end
        end
      end
    end
  end
end
