# frozen_string_literal: true

module TwoFactor
  class DestroyOtpService < ::TwoFactor::BaseService
    def execute
      return error(_('You are not authorized to perform this action')) unless authorized?

      unless user.two_factor_otp_enabled?
        return error(_('This user does not have a one-time password authenticator registered.'))
      end

      disable_two_factor_otp
      { status: :success }
    end

    private

    def authorized?
      can?(current_user, :disable_two_factor, user)
    end

    def disable_two_factor_otp
      ::Users::UpdateService.new(current_user, user: user).execute(&:disable_two_factor_otp!)
    end
  end
end
