# frozen_string_literal: true

module OrganizationInvites
  class CreateService
    include BaseServiceUtility

    def initialize(current_user: nil, params: {})
      @current_user = current_user
      @params = params.dup

      build_attributes
    end

    def execute
      return unless allowed?

      build_attributes
      invite = Organizations::OrganizationInvite.create(params)
      NotificationService.new.owner_invited_to_new_org(invite.organization, invite.email, self.cleartext_token)
    end

    private

    attr_reader :current_user, :params, :cleartext_token

    def allowed?
      return false unless can?(current_user, :create_organization)

      true
    end

    def build_attributes
      params[:inviter_user] = current_user
      params[:access_level] = Gitlab::Access::OWNER

      set_token
    end

    def set_token
      @cleartext_token, params[:token] = Devise.token_generator.generate(Organizations::OrganizationInvite, :token)
    end
  end
end
