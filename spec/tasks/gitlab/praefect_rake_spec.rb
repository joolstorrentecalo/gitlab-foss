# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'gitlab:praefect:replicas', :silence_stdout do
  before do
    Rake.application.rake_require 'tasks/gitlab/praefect'
  end

  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }

  describe 'replicas', :praefect do
    context 'when a valid project id is used as the argument' do
      let(:project_arg) { project.id }

      it "calls praefect info service's replicas method" do
        expect_any_instance_of(Gitlab::GitalyClient::PraefectInfoService).to receive(:replicas).and_call_original

        run_rake_task('gitlab:praefect:replicas', project_arg)
      end

      it 'prints out the expected row' do
        row = /#{project.name}\s+\| #{project.repository.checksum}/

        expect { run_rake_task('gitlab:praefect:replicas', project_arg) }.to output(row).to_stdout
      end
    end

    context 'when an  invalid project id is used as the argument' do
      let(:project_arg) { 'project.id' }

      it 'prints argument must be a valid project_id' do
        expect { run_rake_task('gitlab:praefect:replicas', project_arg) }.to output("argument must be a valid project_id\n").to_stdout
      end

      it 'handles non-existent project_id' do
        non_existent_id = '99999999'
        expect { run_rake_task('gitlab:praefect:replicas', non_existent_id) }.to output(/No project was found with that id/).to_stdout
      end
    end

    context 'when no id is used as an argument' do
      let(:second_project) { create(:project, :repository) }

      it 'prints out the all expected rows' do
        row1 = /#{project.name}\s+\|\s+#{project.repository.checksum}\s+\(primary\)\s+\|\s*/
        row2 = /#{second_project.name}\s+\|\s+#{second_project.repository.checksum}\s+\(primary\)\s+\|\s*/

        separator = /-+/

        expected_output = /#{row1}\n#{separator}\n#{row2}/

        expect { run_rake_task('gitlab:praefect:replicas') }.to output(expected_output).to_stdout
      end
    end

    context 'when a non-existent project id is used as the argument' do
      let(:project_arg) { '2' }

      it "does not call praefect info service's replicas method" do
        expect_any_instance_of(Gitlab::GitalyClient::PraefectInfoService).not_to receive(:replicas)

        run_rake_task('gitlab:praefect:replicas', project_arg)
      end
    end

    context 'when replicas throws an exception' do
      before do
        allow_next_instance_of(Gitlab::GitalyClient::PraefectInfoService) do |instance|
          expect(instance).to receive(:replicas).and_raise("error")
        end
      end

      it 'aborts with the correct error message' do
        expect { run_rake_task('gitlab:praefect:replicas', project.id) }.to output("Something went wrong when getting replicas.\n").to_stdout
      end
    end

    describe '#get_replicas_checksum' do
      let(:project) { create(:project, :repository) }

      context 'when there are replicas' do
        it 'processes replicas and checksums correctly' do
          expected_output = /#{project.name}\s+\|\s+#{project.repository.checksum}\s+\(primary\)\s+/

          expect { run_rake_task('gitlab:praefect:replicas', project.id) }.to output(expected_output).to_stdout
        end
      end

      context 'when there is an exception fetching replicas' do
        before do
          allow_any_instance_of(Gitlab::GitalyClient::PraefectInfoService).to receive(:replicas).and_raise(Gitlab::Git::CommandError, "error")
        end

        it 'returns a hash with only the project name' do
          expected_output = /#{project.name}\s/
          expect { run_rake_task('gitlab:praefect:replicas', project.id) }.to output(expected_output).to_stdout
        end
      end
    end
  end
end
