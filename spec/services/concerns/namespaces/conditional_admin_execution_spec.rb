# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::ConditionalAdminExecution, feature_category: :groups_and_projects do
  let(:conditional_admin_execution_class) { Class.new { include Namespaces::ConditionalAdminExecution } }
  let(:user) { build_stubbed(:user) }
  let(:admin) { build_stubbed(:admin) }

  subject(:instance) { conditional_admin_execution_class.new }

  describe '#admin_mode?' do
    context 'when admin_mode is enabled' do
      before do
        stub_application_setting(admin_mode: true)
      end

      it 'returns true for admin users' do
        expect(instance.send(:admin_mode?, admin)).to eq(true)
      end

      it 'returns false for non-admin users' do
        expect(instance.send(:admin_mode?, user)).to eq(false)
      end
    end

    context 'when admin_mode is disabled' do
      before do
        stub_application_setting(admin_mode: false)
      end

      it 'returns false for admin users' do
        expect(instance.send(:admin_mode?, admin)).to eq(false)
      end

      it 'returns false for non-admin users' do
        expect(instance.send(:admin_mode?, user)).to eq(false)
      end
    end
  end

  describe '#run_conditionally_as_admin' do
    it 'yields to the given block' do
      expect { |b| instance.run_conditionally_as_admin(user, &b) }.to yield_control
    end

    context 'when admin_mode is enabled' do
      before do
        stub_application_setting(admin_mode: true)
      end

      it 'runs in admin mode for admin users' do
        expect(Gitlab::Auth::CurrentUserMode).to receive(:optionally_run_in_admin_mode)
                                                   .with(admin, true)

        instance.run_conditionally_as_admin(admin) { -> {} }
      end

      it 'does not run in admin mode for non-admin users' do
        expect(Gitlab::Auth::CurrentUserMode).to receive(:optionally_run_in_admin_mode)
                                                   .with(user, false)

        instance.run_conditionally_as_admin(user) { -> {} }
      end
    end

    context 'when admin_mode is disabled' do
      before do
        stub_application_setting(admin_mode: false)
      end

      it 'does not run in admin mode for any user' do
        expect(Gitlab::Auth::CurrentUserMode).to receive(:optionally_run_in_admin_mode)
                                                   .with(admin, false)

        instance.run_conditionally_as_admin(admin) { -> {} }
      end
    end
  end
end
