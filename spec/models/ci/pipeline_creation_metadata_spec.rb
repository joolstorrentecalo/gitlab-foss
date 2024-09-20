# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::PipelineCreationMetadata, :clean_gitlab_redis_shared_state, feature_category: :pipeline_composition do
  let_it_be(:merge_request) { build_stubbed(:merge_request) }

  it { is_expected.to validate_presence_of(:id) }
  it { is_expected.to validate_presence_of(:merge_request) }
  it { is_expected.to validate_inclusion_of(:status).in_array(described_class::STATUSES) }

  describe '.find_by' do
    context 'when the pipeline creation exists' do
      it 'finds the status of the pipeline creation from Redis' do
        pipeline_creation = initialize_pipeline_creation
        pipeline_creation.save # rubocop:disable Rails/SaveBang -- This is not a real AR method.

        found_pipeline_creation = described_class.find_by(merge_request: merge_request, id: pipeline_creation.id)

        expect(found_pipeline_creation.status).to eq('creating')
        expect(found_pipeline_creation.id).to eq(pipeline_creation.id)
      end
    end

    context 'when the pipeline creation does not exist' do
      it 'returns nil' do
        pipeline_creation = described_class.find_by(merge_request: merge_request, id: described_class.generate_id)

        expect(pipeline_creation).to be_nil
      end
    end
  end

  describe '.for_merge_request' do
    context 'when there are pipeline creations for the merge request' do
      it 'returns the pipeline creations in the creating state' do
        pipeline_creating = initialize_pipeline_creation

        # rubocop:disable Rails/SaveBang -- Not real AR.
        pipeline_creating.save
        initialize_pipeline_creation(status: 'succeeded').save
        # rubocop:enable Rails/SaveBang

        mr_pipeline_creations = described_class.for_merge_request(merge_request)

        expect(mr_pipeline_creations.map(&:id)).to contain_exactly(pipeline_creating.id)
      end
    end

    context 'when there are no pipeline creations for the merge request' do
      it 'returns an empty array' do
        mr_pipeline_creations = described_class.for_merge_request(merge_request)

        expect(mr_pipeline_creations).to eq([])
      end
    end
  end

  describe '.read_for_merge_request' do
    it 'reads the pipeline creations from the Redis cache' do
      pipeline_creation = initialize_pipeline_creation
      pipeline_creation.save # rubocop:disable Rails/SaveBang -- This is not a real AR method.

      cache_value = described_class.read_for_merge_request(merge_request)

      expect(cache_value[pipeline_creation.id]).to match(a_hash_including('status' => 'creating'))
    end
  end

  describe '.write_for_merge_request' do
    it 'writes the pipeline creation to the Redis cache' do
      described_class.write_for_merge_request(merge_request, [{ status: 'failed' }])

      expect(described_class.read_for_merge_request(merge_request)).to contain_exactly({ 'status' => 'failed' })
    end

    it 'expires the cache after 5 minutes' do
      Gitlab::Redis::SharedState.with do |redis|
        expect(redis).to receive(:set).with(anything, anything, ex: 300)

        described_class.write_for_merge_request(merge_request, 'cache it')
      end
    end
  end

  describe '.merge_request_key' do
    it 'returns the Redis key for the merge request pipeline creations' do
      expect(described_class.merge_request_key(merge_request)).to eq(
        "merge_request:{#{merge_request.id}}:ci_pipeline_creations"
      )
    end
  end

  describe '.generate_id' do
    it 'creates a unique ID for the pipeline creation' do
      expect(SecureRandom).to receive(:uuid)

      described_class.generate_id
    end
  end

  describe '#save' do
    context 'when the pipeline creation is valid' do
      context 'when the cache for the merge request pipeline creations already has a value' do
        it 'merges the new pipeline creation into the cache' do
          initialize_pipeline_creation.save # rubocop:disable Rails/SaveBang -- This is not a real AR method.
          initialize_pipeline_creation.save # rubocop:disable Rails/SaveBang -- This is not a real AR method.

          expect(described_class.read_for_merge_request(merge_request).count).to be(2)
        end
      end

      context 'when the cache for the merge request pipeline creations is empty' do
        it 'writes the pipeline creation to the cache' do
          initialize_pipeline_creation.save # rubocop:disable Rails/SaveBang -- This is not a real AR method.

          expect(described_class.read_for_merge_request(merge_request).count).to be(1)
        end
      end
    end

    context 'when the pipeline creation is invalid' do
      it 'returns false' do
        pipeline_creation = described_class.new

        expect(pipeline_creation.save).to be_falsey
      end
    end
  end

  def initialize_pipeline_creation(status: 'creating')
    described_class.new(
      id: described_class.generate_id,
      merge_request: merge_request,
      status: status
    )
  end
end
