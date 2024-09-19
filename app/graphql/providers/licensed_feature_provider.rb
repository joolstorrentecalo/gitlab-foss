# frozen_string_literal: true

module Providers
  class LicensedFeatureProvider < BaseProvider
    # rubocop: disable Naming/PredicateName -- we use the methods as fields and dont want a ? in the end
    provide :has_issue_weights_feature, -> { licensed_feature_available?(:issue_weights) }, milestone: '17.5'
    provide :has_okrs_feature, -> { licensed_feature_available?(:okrs) }, milestone: '17.5'
    provide :has_epics_feature, -> { licensed_feature_available?(:epics) }, milestone: '17.5'
    provide :has_iterations_feature, -> { licensed_feature_available?(:iterations) }, milestone: '17.5'
    provide :has_subepics_feature, -> { licensed_feature_available?(:subepics) }, milestone: '17.5'
    provide :has_scoped_labels_feature, -> { licensed_feature_available?(:scoped_labels) }, milestone: '17.5'
    provide :has_quality_management_feature, -> {
                                               licensed_feature_available?(:quality_management)
                                             }, milestone: '17.5'
    provide :has_issuable_health_status_feature, -> {
                                                   licensed_feature_available?(:issuable_health_status)
                                                 }, milestone: '17.5'
    # rubocop: enable Naming/PredicateName

    private

    def licensed_feature_available?(feature)
      !!project_or_group&.licensed_feature_available?(feature)
    end
  end
end
