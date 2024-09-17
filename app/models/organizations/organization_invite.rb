# frozen_string_literal: true

module Organizations
  class OrganizationInvite < ApplicationRecord
    belongs_to :organization
    belongs_to :inviter_user, class_name: 'User'

    validates :access_level, presence: true
    validates :token, presence: true

    def self.find_by_token(cleartext_token)
      token_hash = Devise.token_generator.digest(self, :token, cleartext_token)
      find_by(token: token_hash)
    end
  end
end
