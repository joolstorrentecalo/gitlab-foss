# frozen_string_literal: true

# AdjournedGroupDeletionWorker/AdjournedProjectDeletionWorker will destroy days after they are scheduled for deletion.
# If admin_mode is enabled, it will potentially halt group and project deletion.
# The admin_mode flag allows bypassing this check (but no other policy checks), since the admin_mode
# check should have been run when the job was scheduled, not whenever Sidekiq gets around to it.
module Namespaces
  module ConditionalAdminExecution
    extend ActiveSupport::Concern

    # This method should only be used in the context of a Sidekiq worker otherwise it will
    # bypass the admin mode if it's enabled.
    def run_conditionally_as_admin(user)
      Gitlab::Auth::CurrentUserMode.optionally_run_in_admin_mode(user, admin_mode?(user)) { yield }
    end

    private

    def admin_mode?(user)
      # rubocop:disable Cop/UserAdmin -- policy checks are enforced further down the stack
      Gitlab::CurrentSettings.admin_mode && user.admin?
      # rubocop:enable Cop/UserAdmin
    end
  end
end
