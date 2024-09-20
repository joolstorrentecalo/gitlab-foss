# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PersonalAccessTokens::CreateService, feature_category: :system_access do
  shared_examples_for 'a successfully created token' do
    it 'creates personal access token record' do
      expect(subject.success?).to be true
      expect(token.name).to eq(params[:name])
      expect(token.impersonation).to eq(params[:impersonation])
      expect(token.scopes).to eq(params[:scopes])
      expect(token.expires_at).to eq(params[:expires_at])
      expect(token.organization).to eq(organization)
      expect(token.user).to eq(user)
    end

    it 'logs the event' do
      expect(Gitlab::AppLogger).to receive(:info).with(/PAT CREATION: created_by: '#{current_user.username}', created_for: '#{user.username}', token_id: '\d+'/)

      subject
    end

    it 'notifies the user' do
      expect_next_instance_of(NotificationService) do |notification_service|
        expect(notification_service).to receive(:access_token_created).with(user, params[:name])
      end

      subject
    end
  end

  shared_examples_for 'an unsuccessfully created token' do
    it { expect(subject.success?).to be false }
    it { expect(subject.message).to eq('Not permitted to create') }
    it { expect(token).to be_nil }
  end

  describe '#execute' do
    subject { service.execute }

    let(:current_user) { create(:user) }
    let(:organization) { create(:organization) }
    let(:user) { create(:user) }
    let(:params) { { name: 'Test token', impersonation: false, scopes: [:api], expires_at: Date.today + 1.month } }
    let(:service) { described_class.new(current_user: current_user, target_user: user, organization_id: organization.id, params: params, concatenate_errors: false) }
    let(:token) { subject.payload[:personal_access_token] }

    context 'when current_user is an administrator' do
      let(:current_user) { create(:admin) }

      context 'when admin mode is enabled', :enable_admin_mode do
        it_behaves_like 'a successfully created token'
      end

      context 'when admin mode is disabled' do
        it_behaves_like 'an unsuccessfully created token'
      end
    end

    context 'when current_user is not an administrator' do
      context 'target_user is not the same as current_user' do
        it_behaves_like 'an unsuccessfully created token'
      end

      context 'target_user is same as current_user' do
        let(:current_user) { user }

        it_behaves_like 'a successfully created token'
      end
    end

    context 'with no expires_at set', :freeze_time do
      let(:params) { { name: 'Test token', impersonation: false, scopes: [:api] } }
      let(:service) { described_class.new(current_user: user, organization_id: organization.id, target_user: user, params: params) }

      it { expect(subject.payload[:personal_access_token].expires_at).to eq PersonalAccessToken::MAX_PERSONAL_ACCESS_TOKEN_LIFETIME_IN_DAYS.days.from_now.to_date }

      context 'when require_personal_access_token_expiry is set to false' do
        before do
          stub_application_setting(require_personal_access_token_expiry: false)
        end

        it 'returns a nil expiration date' do
          expect(subject.payload[:personal_access_token].expires_at).to be_nil
        end
      end
    end

    context 'when invalid scope' do
      let(:params) { { name: 'Test token', impersonation: false, scopes: [:no_valid], expires_at: Date.today + 1.month } }

      context 'when concatenate_errors: true' do
        let(:service) { described_class.new(current_user: user, target_user: user, organization_id: organization.id, params: params) }

        it { expect(subject.message).to be_an_instance_of(String) }
      end

      context 'when concatenate_errors: false' do
        let(:service) { described_class.new(current_user: user, target_user: user, organization_id: organization.id, params: params, concatenate_errors: false) }

        it { expect(subject.message).to be_an_instance_of(Array) }
      end
    end

    context 'when scopes are present' do
      let(:valid_scopes) { %w[api read_user] }

      subject { build(:personal_access_token, user: user, organization_id: organization.id) }

      before do
        subject.scopes = valid_scopes
      end

      it 'is valid when only scopes are present' do
        expect(subject).to be_valid
      end

      it 'is not valid when both scopes and advanced scopes are present' do
        create(:personal_access_token_advanced_scopes, personal_access_token: subject, organization_id: organization.id)
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("Cannot have both scopes and advanced scopes")
      end
    end

    context 'when advanced scopes are present' do
      before do
        create(:personal_access_token_advanced_scopes, personal_access_token: subject)
      end

      it 'is valid when only advanced scopes are present' do
        expect(subject).to be_valid
      end
    end
  end
end
