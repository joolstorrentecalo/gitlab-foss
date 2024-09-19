# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Get data for the client', feature_category: :team_planning do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:current_user) { create(:user, developer_of: group) }

  let(:params) { {} }

  let(:query) do
    <<~QUERY
      query($fullPath: ID) {
        clientProvider(fullPath: $fullPath) {
          isSignedIn

          features(names: ["workItemEpics", "workItemEpicsList"]) {
            name
            enabled
          }

          paths {
            autocompleteAwardEmojisPath
            epicsListPath
            labelsFetchPath
            groupIssuesPath
            reportAbusePath
            newCommentTemplatePaths
            signInPath
            issuesListPath
            labelsManagePath
            registerPath
            groupPath
          }

          permissions {
            showNewIssueLink
            canBulkEditEpics
            canAdminLabel
            canCreateEpic
          }

          licensedFeatures {
            hasIssueWeightsFeature
            hasOkrsFeature
            hasEpicsFeature
            hasIterationsFeature
            hasIssuableHealthStatusFeature
            hasScopedLabelsFeature
            hasQualityManagementFeature
            hasSubepicsFeature
          }
        }
      }
    QUERY
  end

  subject(:execute_query) do
    post_graphql(query, current_user: current_user, variables: { fullPath: project.full_path })
  end

  RSpec::Matchers.matcher :contains_provided_fields do
    match do |actual|
      actual.each_key do |field|
        key = field.to_s.camelize(:lower)

        expect(actual).to have_key(key), "#{key} is missing"
      end
    end
  end

  describe 'responds to fields' do
    let(:top_level_fields) { [:is_signed_in] }
    let(:permission_fields) { ::Providers::PermissionProvider.provided_fields.keys }
    let(:path_fields) { ::Providers::PathProvider.provided_fields.keys }
    let(:licensed_features_fields) { ::Providers::LicensedFeatureProvider.provided_fields.keys }

    it 'resolves all fields' do
      execute_query

      expect(graphql_data.dig('clientProvider', 'permissions')).to contains_provided_fields(permission_fields)
      expect(graphql_data.dig('clientProvider', 'paths')).to contains_provided_fields(path_fields)
      expect(graphql_data.dig('clientProvider',
        'licensedFeatures')).to contains_provided_fields(licensed_features_fields)
    end

    it 'handles feature flag checks' do
      execute_query

      expect(graphql_data.dig('clientProvider', 'features')).to match_array([
        { "name" => "workItemEpics", "enabled" => false },
        { "name" => "workItemEpicsList", "enabled" => true }
      ])
    end
  end
end
