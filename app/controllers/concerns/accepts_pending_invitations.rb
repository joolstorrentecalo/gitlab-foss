# frozen_string_literal: true

module AcceptsPendingInvitations
  extend ActiveSupport::Concern

  def accept_pending_invitations(user: resource)
    return unless user.active_for_authentication?

    if user.pending_invitations.load.any?
      user.accept_pending_invitations!
      after_pending_invitations_hook
    end

    org_invite = user.pending_organization_invitation
    if org_invite
      org_user = Organizations::OrganizationUser.new(user: user, access_level: org_invite.access_level)
      org_invite.organization.organization_users << org_user
      org_invite.update(accepted_at: Time.current.utc)
    end
  end

  def after_pending_invitations_hook
    # no-op
  end
end
