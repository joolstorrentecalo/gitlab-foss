# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::CreatePipelineWorker, feature_category: :pipeline_composition do
  describe '#perform' do
    let_it_be(:merge_request) { create(:merge_request) }
    let_it_be(:project) { create(:project) }
    let_it_be(:user) { create(:user) }

    let(:worker) { described_class.new }

    subject { worker.perform(project.id, user.id, merge_request.id) }

    context 'when the objects exist' do
      it 'calls the merge request create pipeline service and calls update head pipeline' do
        aggregate_failures do
          expect_next_instance_of(MergeRequests::CreatePipelineService,
            project: project,
            current_user: user,
            params: { allow_duplicate: nil, push_options: nil }) do |service|
            expect(service).to receive(:execute).with(merge_request)
          end

          expect(MergeRequest).to receive(:find_by_id).with(merge_request.id).and_return(merge_request)
          expect(merge_request).to receive(:update_head_pipeline)

          subject
        end
      end

      context 'when given a pipeline creation ID', :clean_gitlab_redis_shared_state do
        before do
          # rubocop:disable Rails/SaveBang -- This method call is not ActiveRecord#save
          Ci::PipelineCreationMetadata.new(id: '123', merge_request: merge_request, status: 'creating').save
          # rubocop:enable Rails/SaveBang
        end

        context 'when pipeline creation succeeds' do
          it 'updates the creation status to succeeded' do
            allow_next_instance_of(MergeRequests::CreatePipelineService) do |service|
              allow(service).to receive(:execute).and_return(
                ServiceResponse.success(payload: instance_double(Ci::Pipeline, id: '456'))
              )
            end

            worker.perform(project.id, user.id, merge_request.id, pipeline_creation_id: '123')

            creation = Ci::PipelineCreationMetadata.find_by(id: '123', merge_request: merge_request)
            expect(creation.status).to eq('succeeded')
            expect(creation.pipeline_id).to eq('456')
          end
        end

        context 'when pipeline creation fails' do
          it 'updates the creation status to failed' do
            allow_next_instance_of(MergeRequests::CreatePipelineService) do |service|
              allow(service).to receive(:execute).and_return(ServiceResponse.error(message: 'failed'))
            end

            worker.perform(project.id, user.id, merge_request.id, pipeline_creation_id: '123')

            expect(
              Ci::PipelineCreationMetadata.find_by(id: '123', merge_request: merge_request).status
            ).to eq('failed')
          end
        end
      end

      context 'when push options are passed as Hash to the worker' do
        let(:extra_params) { { 'push_options' => { 'ci' => { 'skip' => true } } } }

        subject { worker.perform(project.id, user.id, merge_request.id, extra_params) }

        it 'calls the merge request create pipeline service and calls update head pipeline' do
          aggregate_failures do
            expect_next_instance_of(MergeRequests::CreatePipelineService,
              project: project,
              current_user: user,
              params: { allow_duplicate: nil, push_options: { ci: { skip: true } } }) do |service|
              expect(service).to receive(:execute).with(merge_request)
            end

            expect(MergeRequest).to receive(:find_by_id).with(merge_request.id).and_return(merge_request)
            expect(merge_request).to receive(:update_head_pipeline)

            subject
          end
        end
      end
    end

    shared_examples 'when object does not exist' do
      it 'does not call the create pipeline service' do
        expect(MergeRequests::CreatePipelineService).not_to receive(:new)

        expect { subject }.not_to raise_exception
      end
    end

    context 'when the project does not exist' do
      before do
        project.destroy!
      end

      it_behaves_like 'when object does not exist'
    end

    context 'when the user does not exist' do
      before do
        user.destroy!
      end

      it_behaves_like 'when object does not exist'
    end

    context 'when the merge request does not exist' do
      before do
        merge_request.destroy!
      end

      it_behaves_like 'when object does not exist'
    end
  end
end
