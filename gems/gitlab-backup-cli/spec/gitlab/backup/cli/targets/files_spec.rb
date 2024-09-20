# frozen_string_literal: true

require 'spec_helper'
require 'active_support/testing/time_helpers'
require '../../lib/gitlab/popen'

RSpec.describe Gitlab::Backup::Cli::Targets::Files, feature_category: :backup_restore do
  include ActiveSupport::Testing::TimeHelpers

  let(:status_0) { instance_double(Process::Status, success?: true, exitstatus: 0) }
  let(:status_1) { instance_double(Process::Status, success?: false, exitstatus: 1) }
  let(:pipeline_status_success) { Gitlab::Backup::Cli::Shell::Pipeline::Result.new(status_list: [status_0, status_0]) }
  let(:pipeline_status_failed) { Gitlab::Backup::Cli::Shell::Pipeline::Result.new(status_list: [status_1, status_1]) }
  let(:tmp_backup_restore_dir) { Dir.mktmpdir('files-target-restore') }

  let(:context) { build_fake_context }

  let!(:workdir) do
    FileUtils.mkdir_p(context.backup_basedir)
    Pathname(Dir.mktmpdir('backup', context.backup_basedir))
  end

  let(:restore_target) { File.realpath(tmp_backup_restore_dir) }

  let(:backup_target) do
    %w[@pages.tmp lost+found @hashed].each do |folder|
      path = Pathname(tmp_backup_restore_dir).join(folder, 'something', 'else')

      FileUtils.mkdir_p(path)
      FileUtils.touch(path.join('artifacts.zip'))
    end

    File.realpath(tmp_backup_restore_dir)
  end

  before do
    allow(FileUtils).to receive(:mv).and_return(true)
    allow(File).to receive(:exist?).and_return(true)
  end

  after do
    FileUtils.rm_rf([restore_target, backup_target], secure: true)
  end

  describe '#restore' do
    subject(:files) { described_class.new(restore_target) }

    let(:timestamp) { Time.utc(2017, 3, 22) }

    around do |example|
      travel_to(timestamp) { example.run }
    end

    describe 'folders with permission' do
      let(:existing_content) { File.join(restore_target, 'sample1') }

      before do
        FileUtils.touch(existing_content)
      end

      it 'moves all necessary files' do
        expect_next_instance_of(Gitlab::Backup::Cli::Shell::Pipeline) do |pipeline|
          expect(pipeline).to receive(:run!).and_return(pipeline_status_success)
        end

        tmp_dir = tmp_backup_restore_dir.join('tmp', "registry.#{Time.now.to_i}")
        expect(FileUtils).to receive(:mv).with([existing_content], tmp_dir)

        files.restore('registry.tar.gz', workdir, 'backup_id')
      end

      it 'raises no errors' do
        expect_next_instance_of(Gitlab::Backup::Cli::Shell::Pipeline) do |pipeline|
          expect(pipeline).to receive(:run!).and_return(pipeline_status_success)
        end

        expect { files.restore('registry.tar.gz', workdir, 'backup_id') }.not_to raise_error
      end

      it 'calls tar command with unlink' do
        expect_next_instance_of(Gitlab::Backup::Cli::Shell::Pipeline) do |pipeline|
          tar_cmd = pipeline.shell_commands[1]

          expect(tar_cmd.cmd_args).to include('--unlink-first')
          expect(tar_cmd.cmd_args).to include('--recursive-unlink')

          expect(pipeline).to receive(:run!).and_return(pipeline_status_success)
        end

        files.restore('registry.tar.gz', workdir, 'backup_id')
      end

      it 'raises an error on failure' do
        expect_next_instance_of(Gitlab::Backup::Cli::Shell::Pipeline) do |pipeline|
          expect(pipeline).to receive(:run!).and_return(pipeline_status_failed)
        end

        expect { files.restore('registry.tar.gz', workdir, 'backup_id') }.to raise_error(/Restore operation failed:/)
      end
    end

    describe 'folders without permissions' do
      before do
        FileUtils.touch('registry.tar.gz')
        allow(FileUtils).to receive(:mv).and_raise(Errno::EACCES)
        allow(files).to receive(:run!).and_return([[true, true], ''])
        allow_next_instance_of(Gitlab::Backup::Cli::Shell::Pipeline) do |pipeline|
          allow(pipeline).to receive(:run!).and_return(pipeline_status_success)
        end
      end

      after do
        FileUtils.rm_rf('registry.tar.gz')
      end

      it 'shows error message' do
        expect(files).to receive(:access_denied_error).with(restore_target)

        files.restore('registry.tar.gz', workdir, 'backup_id')
      end
    end

    describe 'folders that are a mountpoint' do
      before do
        allow(FileUtils).to receive(:mv).and_raise(Errno::EBUSY)
        allow(files).to receive(:run!).and_return([[true, true], ''])
        allow_next_instance_of(Gitlab::Backup::Cli::Shell::Pipeline) do |pipeline|
          allow(pipeline).to receive(:run!).and_return(pipeline_status_success)
        end
      end

      it 'shows error message' do
        expect(files).to receive(:resource_busy_error).with(restore_target)
                                                      .and_call_original

        expect { files.restore('registry.tar.gz', workdir, 'backup_id') }.to raise_error(/is a mountpoint/)
      end
    end
  end

  describe '#dump' do
    subject(:files) do
      described_class.new(backup_target, excludes: ['@pages.tmp'])
    end

    it 'raises no errors' do
      expect { files.dump('registry.tar.gz', 'backup_id') }.not_to raise_error
    end

    it 'excludes tmp dirs from archive' do
      expect_next_instance_of(Gitlab::Backup::Cli::Shell::Pipeline) do |pipeline|
        tar_cmd = pipeline.shell_commands[0]

        expect(tar_cmd.cmd_args).to include('--exclude=lost+found')
        expect(tar_cmd.cmd_args).to include('--exclude=./@pages.tmp')

        allow(pipeline).to receive(:run!).and_call_original
      end

      files.dump('registry.tar.gz', 'backup_id')
    end

    it 'raises an error on failure' do
      expect_next_instance_of(Gitlab::Backup::Cli::Shell::Pipeline) do |pipeline|
        expect(pipeline).to receive(:success?).and_return(false)
      end

      expect do
        files.dump('registry.tar.gz', 'backup_id')
      end.to raise_error(/Failed to create compressed file/)
    end
  end

  describe '#tar_ignore_non_success?' do
    subject(:files) do
      described_class.new('/var/gitlab-registry')
    end

    context 'if `tar` command exits with 1 exitstatus' do
      it 'returns true' do
        expect(
          files.tar_ignore_non_success?(1, 'any_output')
        ).to be_truthy
      end

      it 'outputs a warning' do
        expect do
          files.tar_ignore_non_success?(1, 'any_output')
        end.to output(/Ignoring tar exit status 1/).to_stdout
      end
    end

    context 'if `tar` command exits with 2 exitstatus with non-critical warning' do
      before do
        allow(files).to receive(:noncritical_warning?).and_return(true)
      end

      it 'returns true' do
        expect(
          files.tar_ignore_non_success?(2, 'any_output')
        ).to be_truthy
      end

      it 'outputs a warning' do
        expect do
          files.tar_ignore_non_success?(2, 'any_output')
        end.to output(/Ignoring non-success exit status/).to_stdout
      end
    end

    context 'if `tar` command exits with any other unlisted error' do
      before do
        allow(files).to receive(:noncritical_warning?).and_return(false)
      end

      it 'returns false' do
        expect(
          files.tar_ignore_non_success?(2, 'any_output')
        ).to be_falsey
      end
    end
  end

  describe '#noncritical_warning?' do
    subject(:files) do
      described_class.new('/var/gitlab-registry')
    end

    it 'returns true if given text matches noncritical warnings list' do
      expect(
        files.noncritical_warning?('tar: .: Cannot mkdir: No such file or directory')
      ).to be_truthy

      expect(
        files.noncritical_warning?('gtar: .: Cannot mkdir: No such file or directory')
      ).to be_truthy
    end

    it 'returns false otherwise' do
      expect(
        files.noncritical_warning?('unknown message')
      ).to be_falsey
    end
  end
end
