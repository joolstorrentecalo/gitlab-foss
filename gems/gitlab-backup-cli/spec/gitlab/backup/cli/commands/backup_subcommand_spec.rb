# frozen_string_literal: true

RSpec.describe Gitlab::Backup::Cli::Commands::BackupSubcommand do
  let(:available_options) do
    {
      'backup_bucket' => 'backup_bucket',
      'not_an_executor_option' => 'not_an_executor_option',
      'registry_bucket' => 'registry_bucket',
      'service_account_file' => 'service_account_file',
      'wait_for_completion' => 'wait_for_completion'
    }
  end

  before do
    allow_next_instance_of(described_class) do |backup_subcommand|
      allow(backup_subcommand).to receive(:parent_options).and_return(available_options)
    end
  end

  describe "#executor_options" do
    it "returns the expected array" do
      expect(described_class.new.send(:executor_options).keys).to match_array(
        Gitlab::Backup::Cli::BaseExecutor::CMD_OPTIONS
      )
    end
  end
end
