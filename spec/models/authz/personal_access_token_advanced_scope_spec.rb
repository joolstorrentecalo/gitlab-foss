# frozen_string_literal: true

require 'spec_helper'
RSpec.describe Authz::PersonalAccessTokenAdvancedScope, type: :model, feature_category: :user_management do
  let(:personal_access_token) { create(:personal_access_token) }

  describe 'validations' do
    context 'when validating presence' do
      let(:http_methods) { ['GET'] }
      let(:path_string) { '^/api/v4/test$' }

      subject(:advanced_scope) do
        build(:personal_access_token_advanced_scopes, http_methods: http_methods, path_string: path_string,
          personal_access_token: personal_access_token)
      end

      before do
        allow(advanced_scope).to receive(:validate_http_methods).and_return(true)
        allow(advanced_scope).to receive(:validate_path_string).and_return(true)
        allow(advanced_scope).to receive(:personal_access_token_advanced_scopes_limit).and_return(true)
      end

      context 'on http_methods' do
        let(:http_methods) { nil }

        it 'is not valid' do
          expect(advanced_scope).not_to be_valid
          expect(advanced_scope.errors[:http_methods]).to include("can't be blank")
        end
      end

      context 'on path_string' do
        let(:path_string) { nil }

        it 'is not valid' do
          expect(advanced_scope).not_to be_valid
          expect(advanced_scope.errors[:path_string]).to include("can't be blank")
        end
      end
    end

    context 'when the advanced scopes limit is reached' do
      let(:line_max_length) { described_class::ADVANCED_SCOPES_MAX_LINES }

      before do
        line_max_length.times do
          create(:personal_access_token_advanced_scopes, personal_access_token: personal_access_token)
        end
      end

      it 'is not valid' do
        new_scope = build(:personal_access_token_advanced_scopes, personal_access_token: personal_access_token)
        expect(new_scope).not_to be_valid
        expect(new_scope.errors[:advanced_scopes]).to include(
          "is too long (#{line_max_length}). The maximum size is #{line_max_length}.")
      end
    end

    context 'when the advanced scopes limit is not reached' do
      before do
        (described_class::ADVANCED_SCOPES_MAX_LINES - 1).times do
          create(:personal_access_token_advanced_scopes, personal_access_token: personal_access_token)
        end
      end

      it 'is valid' do
        new_scope = build(:personal_access_token_advanced_scopes, personal_access_token: personal_access_token)
        expect(new_scope).to be_valid
      end
    end

    context 'when an invalid HTTP method is supplied' do
      let(:invalid_method) { 'INVALID' }
      let(:http_methods) { [described_class::VALID_HTTP_METHODS.first, invalid_method] }

      it 'is not valid' do
        invalid_method_token = build(:personal_access_token_advanced_scopes, http_methods: http_methods,
          personal_access_token: personal_access_token)
        expect(invalid_method_token).not_to be_valid
        expect(invalid_method_token.errors[:http_methods]).to include("contains invalid methods: #{invalid_method}")
      end
    end
  end
end
