# frozen_string_literal: true

module Emails
  module Organizations
    extend ActiveSupport::Concern

    def owner_invited_to_new_org_email(organization, email_address, cleartext_token)
      @cleartext_token = cleartext_token

      email_with_layout(
        to: email_address,
        subject: subject("Org Invite"))
    end
  end
end
