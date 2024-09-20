# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AccessTokenValidationService, feature_category: :system_access do
  describe ".include_any_scope?" do
    let(:request) { double("request") }

    it "returns true if the required scope is present in the token's scopes" do
      token = double("token", scopes: [:api, :read_user])
      scopes = [:api]

      expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(true)
    end

    it "returns true if more than one of the required scopes is present in the token's scopes" do
      token = double("token", scopes: [:api, :read_user, :other_scope])
      scopes = [:api, :other_scope]

      expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(true)
    end

    it "returns true if the list of required scopes is an exact match for the token's scopes" do
      token = double("token", scopes: [:api, :read_user, :other_scope])
      scopes = [:api, :read_user, :other_scope]

      expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(true)
    end

    it "returns true if the list of required scopes contains all of the token's scopes, in addition to others" do
      token = double("token", scopes: [:api, :read_user])
      scopes = [:api, :read_user, :other_scope]

      expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(true)
    end

    it 'returns true if the list of required scopes is blank' do
      token = double("token", scopes: [])
      scopes = []

      expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(true)
    end

    it "returns false if there are no scopes in common between the required scopes and the token scopes" do
      token = double("token", scopes: [:api, :read_user])
      scopes = [:other_scope]

      expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(false)
    end

    context "conditions" do
      it "ignores any scopes whose `if` condition returns false" do
        token = double("token", scopes: [:api, :read_user])
        scopes = [API::Scope.new(:api, if: ->(_) { false })]

        expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(false)
      end

      it "does not ignore scopes whose `if` condition is not set" do
        token = double("token", scopes: [:api, :read_user])
        scopes = [API::Scope.new(:api, if: ->(_) { false }), :read_user]

        expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(true)
      end

      it "does not ignore scopes whose `if` condition returns true" do
        token = double("token", scopes: [:api, :read_user])
        scopes = [API::Scope.new(:api, if: ->(_) { true }), API::Scope.new(:read_user, if: ->(_) { false })]

        expect(described_class.new(token, request: request).include_any_scope?(scopes)).to be(true)
      end
    end
  end

  describe '#validate_advanced_scopes!' do
    let(:request) { double('request') }
    let(:http_methods) { ['GET'] }
    let(:path_string) { '^/some_path$' }
    let(:request_path) { '/some_path' }
    let(:request_method) { 'GET' }
    let(:personal_access_token) { create(:personal_access_token) }
    let!(:advanced_scoped_token) do
      create(:personal_access_token_advanced_scopes, http_methods: http_methods,
        path_string: path_string, personal_access_token: personal_access_token)
    end

    before do
      allow(Gitlab::UntrustedRegexp).to receive(:new).and_call_original
      allow(request).to receive(:request_method).and_return(request_method)
      allow(request).to receive(:path).and_return(request_path)
    end

    context 'when the request path is matching personal access token advanced scopes regex' do
      let(:path_string) { '^/api/v4/issues/\d*$' }
      let(:request_path) { '/api/v4/issues/91123' }

      it 'returns a valid result' do
        expect(described_class.new(personal_access_token, request: request).validate_advanced_scopes!).to eq(:valid)
      end
    end

    context 'when the request method is matching personal access token advanced scopes methods' do
      let(:http_methods) { ['GET'] }
      let(:request_method) { 'GET' }

      it 'returns a valid result' do
        expect(described_class.new(personal_access_token, request: request).validate_advanced_scopes!).to eq(:valid)
      end
    end

    context 'when the request method does not match any personal access token advanced scopes methods' do
      let(:http_methods) { ['POST'] }
      let(:request_method) { 'GET' }

      it 'returns an insufficient scope result' do
        expect(described_class.new(personal_access_token,
          request: request).validate_advanced_scopes!).to eq(:insufficient_scope)
      end
    end

    context 'when the request path does not match any personal access token advanced scopes path' do
      let(:path_string) { '^/some_path/$' }
      let(:request_path) { '/some_other_path' }

      it 'returns an insufficient scope result' do
        expect(described_class.new(personal_access_token,
          request: request).validate_advanced_scopes!).to eq(:insufficient_scope)
      end
    end

    context 'when multiple scopes exist on the token' do
      let!(:first_advanced_scopes_for_token) do
        create(:personal_access_token_advanced_scopes, http_methods: %w[GET POST],
          path_string: '^/api/v4/issues/\d*$', personal_access_token: personal_access_token)
      end

      let!(:second_advanced_scopes_for_token) do
        create(:personal_access_token_advanced_scopes, http_methods: ['GET'],
          path_string: '^/api/v4/projects/\d+/merge_requests$', personal_access_token: personal_access_token)
      end

      context 'and one matches the request path and method' do
        let(:request_path) { '/api/v4/issues/91123' }
        let(:request_method) { 'GET' }

        it 'returns a valid result' do
          expect(described_class.new(personal_access_token, request: request).validate_advanced_scopes!).to eq(:valid)
        end
      end

      context 'and the path and http verb match different advanced scopes' do
        let(:request_path) { '/api/v4/projects/1234/merge_requests' }
        let(:request_method) { 'POST' }

        it 'returns an insufficient scope result' do
          expect(described_class.new(personal_access_token,
            request: request).validate_advanced_scopes!).to eq(:insufficient_scope)
        end
      end

      context 'and none of them matches the scope and path of the request' do
        let(:request_path) { '/api/v4/projects/1234/members' }

        it 'returns an insufficient scope result' do
          expect(described_class.new(personal_access_token,
            request: request).validate_advanced_scopes!).to eq(:insufficient_scope)
        end
      end
    end
  end
end
