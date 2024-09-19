# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::CachePrimaryKeyLookupResult, feature_category: :database do
  let(:test_class) do
    Class.new(ApplicationRecord) do
      include Gitlab::CachePrimaryKeyLookupResult

      self.table_name = :namespaces

      def self.name
        'Namespace'
      end
    end
  end

  describe '.class_cache_fingerprint' do
    let(:identical_test_class) do
      Class.new(ApplicationRecord) do
        include Gitlab::CachePrimaryKeyLookupResult

        self.table_name = :namespaces

        def self.name
          'Namespace'
        end
      end
    end

    let(:different_test_class) do
      Class.new(ApplicationRecord) do
        include Gitlab::CachePrimaryKeyLookupResult

        self.table_name = :namespaces

        def self.name
          'Namespace'
        end

        def self.foo
          'foo'
        end
      end
    end

    let(:base_fingerprint) { test_class.class_cache_fingerprint }

    context 'when the classes are the same' do
      it 'returns identical fingerprints' do
        expect(test_class.class_cache_fingerprint).to eq(identical_test_class.class_cache_fingerprint)
      end
    end

    context 'when the classes are different' do
      it 'returns different fingerprints' do
        expect(test_class.class_cache_fingerprint).not_to eq(different_test_class.class_cache_fingerprint)
      end
    end
  end

  describe '.primary_key_lookup_cache_expiration' do
    let(:default_expiration) { 60.seconds }

    before do
      test_class.instance_variable_set(:@cache_expiration_times, cache_expiration_times)
    end

    context 'when the key exists' do
      let(:cache_expiration_times) { { 'namespaces' => 90 } }

      it 'returns the specified value' do
        expect(test_class.primary_key_lookup_cache_expiration).to eq(90.seconds)
      end
    end

    context 'when the key does not exist' do
      let(:cache_expiration_times) { { 'users' => 90 } }

      it 'returns the specified value' do
        expect(test_class.primary_key_lookup_cache_expiration).to eq(default_expiration)
      end
    end
  end

  context 'when the feature flag is disabled' do
    describe '.find' do
      before do
        stub_feature_flags(cache_primary_key_lookup_result: false)
      end

      it 'does not cache the record', :use_clean_rails_redis_caching do
        namespace = create(:user_namespace)
        connection_spy = Namespace.connection
        allow(connection_spy).to receive(:select_all).and_call_original

        2.times do
          Namespace.find(namespace.id)
        end

        expect(connection_spy).to have_received(:select_all).exactly(2).times
      end
    end
  end

  context 'when the feature flag is enabled' do
    before do
      stub_feature_flags(cache_primary_key_lookup_result: true)
    end

    describe '.find' do
      it 'caches the record', :use_clean_rails_redis_caching do
        namespace = create(:user_namespace)
        # Need to clear the cache before proceeding because the creating the factory_bot
        # model adds it to the cache
        Rails.cache.clear
        connection_spy = Namespace.connection
        allow(connection_spy).to receive(:select_all).and_call_original

        2.times do
          Namespace.find(namespace.id)
        end

        expect(connection_spy).to have_received(:select_all).exactly(1).time
      end
    end

    describe '.find_by_sql' do
      it 'caches the record', :use_clean_rails_redis_caching do
        namespace = create(:user_namespace)
        # Need to clear the cache before proceeding because the creating the factory_bot
        # model adds it to the cache
        Rails.cache.clear
        query = "SELECT * FROM \"namespaces\" WHERE \"namespaces\".\"id\" = #{namespace.id} LIMIT 1"
        connection_spy = Namespace.connection
        allow(connection_spy).to receive(:select_all).and_call_original

        2.times do
          Namespace.find_by_sql(query)
        end

        expect(connection_spy).to have_received(:select_all).exactly(1).time
      end
    end

    describe '#delete_cache_entry' do
      it 'invalidates the cache entry upon update', :use_clean_rails_redis_caching do
        namespace = create(:user_namespace)
        namespace_cache_key = namespace.primary_key_lookup_cache_key
        expect(Rails.cache.read(namespace_cache_key)).not_to be_nil
        namespace.description_html = 'Updated text'
        namespace.save!
        expect(Rails.cache.read(namespace_cache_key)).to be_nil
      end
    end
  end
end
