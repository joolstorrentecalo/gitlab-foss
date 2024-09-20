# frozen_string_literal: true

RSpec.describe Gitlab::Backup::Cli do
  it "has a version number" do
    expect(Gitlab::Backup::Cli::VERSION).not_to be nil
  end

  describe '.compression_command' do
    it 'returns a Shell::Command instance for gzip compression' do
      command = described_class.compression_command

      expect(command).to be_a(Gitlab::Backup::Cli::Shell::Command)
      expect(command.cmd_args).to eq(['gzip', '-c', '-1'])
    end
  end

  describe '.decompression_command' do
    it 'returns a Shell::Command instance for gzip decompression' do
      command = described_class.decompression_command

      expect(command).to be_a(Gitlab::Backup::Cli::Shell::Command)
      expect(command.cmd_args).to eq(['gzip', '-cd'])
    end
  end
end
