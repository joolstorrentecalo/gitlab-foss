# frozen_string_literal: true

module Members
  class AccessDeniedMailerPreview < ActionMailer::Preview
    def email
      Members::AccessDeniedMailer.with(member: member).email.message # rubocop:disable CodeReuse/ActiveRecord -- false positive
    end

    private

    def member
      Member.non_invite.last
    end
  end
end
