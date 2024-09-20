# frozen_string_literal: true

module Authz
  class PersonalAccessTokenAdvancedScope < ApplicationRecord
    belongs_to :personal_access_token
    belongs_to :organization

    before_validation :set_organization_id

    validates :http_methods, presence: true
    validates :path_string, presence: true

    validate :validate_http_methods
    validate :validate_path_string
    validate :personal_access_token_advanced_scopes_limit, on: :create

    ADVANCED_SCOPES_MAX_LINES = 10
    VALID_HTTP_METHODS = %w[GET POST PUT DELETE PATCH HEAD OPTIONS].freeze

    def path_regex
      Gitlab::UntrustedRegexp.new(path_string)
    end

    private

    def validate_path_string
      Gitlab::UntrustedRegexp.new(path_string)
    rescue RegexpError => e
      errors.add(:path_string, "error in \"#{path_string}\" : #{e.message}")
    end

    def personal_access_token_advanced_scopes_limit
      return unless personal_access_token.personal_access_token_advanced_scopes.count >= ADVANCED_SCOPES_MAX_LINES

      errors.add :advanced_scopes,
        format(_("is too long (%{current_value}). The maximum size is %{max_size}."),
          current_value: personal_access_token.personal_access_token_advanced_scopes.count,
          max_size: ADVANCED_SCOPES_MAX_LINES)
    end

    def validate_http_methods
      invalid_methods = http_methods - VALID_HTTP_METHODS
      return unless invalid_methods.any?

      errors.add(:http_methods, "contains invalid methods: #{invalid_methods.join(', ')}")
    end

    def set_organization_id
      self.organization_id = personal_access_token.organization_id
    end
  end
end
