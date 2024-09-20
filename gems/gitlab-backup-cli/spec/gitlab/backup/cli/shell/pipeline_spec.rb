# frozen_string_literal: true

RSpec.describe Gitlab::Backup::Cli::Shell::Pipeline do
  let(:command) { Gitlab::Backup::Cli::Shell::Command }
  let(:printf_command) { command.new('printf "3\n2\n1"') }
  let(:sort_command) { command.new('sort') }

  subject(:pipeline) { described_class }

  it { respond_to :shell_commands }

  describe '#initialize' do
    it 'accepts a single argument' do
      expect { pipeline.new(printf_command) }.not_to raise_exception
    end

    it 'accepts multiple arguments' do
      expect { pipeline.new(printf_command, sort_command) }.not_to raise_exception
    end
  end

  describe '#run!' do
    it 'returns a Pipeline::Status' do
      true_command = command.new('true')

      result = pipeline.new(true_command, true_command).run!

      expect(result).to be_a(Gitlab::Backup::Cli::Shell::Pipeline::Result)
    end

    context 'with Pipeline::Status' do
      it 'includes stderr from the executed pipeline' do
        expected_output = 'my custom error content'
        err_command = command.new("echo #{expected_output} > /dev/stderr")

        result = pipeline.new(err_command).run!

        expect(result.stderr.chomp).to eq(expected_output)
      end

      it 'includes a list of Process::Status from the executed pipeline' do
        true_command = command.new('true')

        result = pipeline.new(true_command, true_command).run!

        expect(result.status_list).to all be_a(Process::Status)
        expect(result.status_list).to all respond_to(:exited?, :termsig, :stopsig, :exitstatus, :success?, :pid)
      end

      it 'includes a list of Process::Status that handles exit signals' do
        false_command = command.new('false')

        result = pipeline.new(false_command, false_command).run!

        expect(result.status_list).to all satisfy { |status| !status.success? }
        expect(result.status_list).to all satisfy { |status| status.exitstatus == 1 }
      end
    end

    it 'accepts stdin and stdout redirection' do
      echo_command = command.new(%(ruby -e "print 'stdin is : ' + STDIN.readline"))
      input_r, input_w = IO.pipe
      input_w.sync = true
      input_w.print 'my custom content'
      input_w.close

      output_r, output_w = IO.pipe

      result = pipeline.new(echo_command).run!(input: input_r, output: output_w)

      input_r.close
      output_w.close
      output = output_r.read
      output_r.close

      expect(result.status_list.size).to eq(1)
      expect(result.status_list[0]).to be_success
      expect(output).to match(/stdin is : my custom content/)
    end
  end

  describe '#success?' do
    let(:pipeline) { described_class.new }
    let(:status_0) { instance_double(Process::Status, success?: true, exitstatus: 0) }
    let(:status_1) { instance_double(Process::Status, success?: false, exitstatus: 1) }
    let(:pipeline_status_empty) { described_class::Result.new(status_list: []) }
    let(:pipeline_status_success) { described_class::Result.new(status_list: [status_0, status_0]) }
    let(:pipeline_status_failed) { described_class::Result.new(status_list: [status_1, status_1]) }

    before do
      allow(pipeline).to receive(:result).and_return(result)
    end

    context 'when there is no result' do
      let(:result) { nil }

      it 'returns false' do
        expect(pipeline.success?).to be false
      end
    end

    context 'when there is no status list' do
      let(:result) { described_class::Result.new }

      it 'returns false' do
        expect(pipeline.success?).to be false
      end
    end

    context 'when there are no status results' do
      let(:result) { pipeline_status_empty }

      it 'returns false' do
        expect(pipeline.success?).to be false
      end
    end

    context 'when one command is unsuccessful' do
      let(:result) { pipeline_status_failed }

      it 'returns false' do
        expect(pipeline.success?).to be false
      end
    end

    context 'when all commands are successful' do
      let(:result) { pipeline_status_success }

      it 'returns true' do
        expect(pipeline.success?).to be true
      end
    end
  end
end
