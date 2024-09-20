# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AntiAbuse::BanDuplicateUsersWorker, :clean_gitlab_redis_shared_state, feature_category: :instance_resiliency do
  let(:worker) { described_class.new }
  let_it_be_with_reload(:user) { create(:user, email: 'user+1@example.com') }

  subject(:perform) { worker.perform(user.id) }

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { [user.id] }
  end

  shared_examples 'bans the user' do
    specify do
      expect { perform }.to change { duplicate_user.reload.banned? }.from(false).to(true)
    end

    it 'records a custom attribute' do
      expect { perform }.to change { UserCustomAttribute.count }.by(1)
      expect(duplicate_user.custom_attributes.by_key(UserCustomAttribute::AUTO_BANNED_BY).first.value)
        .to eq(ban_reason)
    end

    it 'logs the event' do
      expect(Gitlab::AppLogger).to receive(:info).with(
        message: "Duplicate user auto-ban",
        reason: ban_reason,
        username: duplicate_user.username.to_s,
        user_id: duplicate_user.id,
        email: duplicate_user.email.to_s,
        triggered_by_banned_user_id: user.id,
        triggered_by_banned_username: user.username
      )

      perform
    end
  end

  shared_examples 'does not ban the user' do
    specify do
      expect { perform }.not_to change { duplicate_user.reload.banned? }
      expect(duplicate_user.custom_attributes.by_key(UserCustomAttribute::AUTO_BANNED_BY).first).to be_nil
      expect(Gitlab::AppLogger).not_to receive(:info)
    end
  end

  shared_examples 'executing the ban duplicate users worker' do
    context "when the user has not been banned" do
      it_behaves_like 'does not ban the user'
    end

    context "when the user has been banned" do
      before do
        user.ban!
      end

      it_behaves_like 'bans the user'
    end
  end

  describe 'ban users with the same detumbled email address' do
    let(:ban_reason) { "User #{user.id} was banned with the same detumbled email address" }
    let_it_be_with_reload(:duplicate_user) { create(:user, email: 'user+2@example.com') }

    it_behaves_like 'executing the ban duplicate users worker'

    context "when the auto_ban_via_detumbled_email feature is disabled" do
      before do
        user.ban!
        stub_feature_flags(auto_ban_via_detumbled_email: false)
      end

      it_behaves_like 'does not ban the user'
    end
  end
end
