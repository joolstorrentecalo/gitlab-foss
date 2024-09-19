# frozen_string_literal: true

module Providers
  class PathProvider < BaseProvider
    include Rails.application.routes.url_helpers

    provide :group_path, -> { group&.path }, milestone: '17.5'
    provide :register_path, -> { '' }, milestone: '17.5'
    provide :sign_in_path, -> { '' }, milestone: '17.5'
    provide :new_comment_template_paths, -> { profile_comment_templates_path }, milestone: '17.5'
    provide :report_abuse_path, -> { add_category_abuse_reports_path }, milestone: '17.5'

    provide :autocomplete_award_emojis_path, milestone: '17.5' do
      Rails.application.routes.url_helpers.autocomplete_award_emojis_path
    end

    provide :issues_list_path, milestone: '17.5' do
      next unless group

      group.present? ? issues_group_path(group) : project_issues_path(project)
    end

    provide :labels_manage_path, milestone: '17.5' do
      next unless group

      group.present? ? group_labels_path(group) : project_labels_path(project)
    end

    provide :group_issues_path, milestone: '17.5' do
      next '' unless group

      issues_group_path(group)
    end

    provide :labels_fetch_path, milestone: '17.5' do
      next '' unless group

      group_labels_path(group, format: :json, only_group_labels: true, include_ancestor_groups: true)
    end

    provide :epics_list_path, milestone: '17.5' do
      next '' unless group

      group_epics_path(group)
    end
  end
end
