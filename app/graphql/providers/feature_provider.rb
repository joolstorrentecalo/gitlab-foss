# frozen_string_literal: true

module Providers
  class FeatureProvider < BaseProvider
    def enabled?(name)
      if respond_to?(name)
        public_send(name) # rubocop:disable GitlabSecurity/PublicSend -- otherwise not possible to override feature flag checks
      else
        Feature.enabled?(name, current_user)
      end
    end

    provide :work_item_epics, -> { false }
  end
end
