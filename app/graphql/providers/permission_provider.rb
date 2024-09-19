# frozen_string_literal: true

module Providers
  class PermissionProvider < BaseProvider
    provide :show_new_issue_link, -> { Ability.allowed?(current_user, :create_work_item, group) }, milestone: '17.5'
    provide :can_bulk_edit_epics, -> { Ability.allowed?(current_user, :bulk_admin_epic, group) }, milestone: '17.5'
    provide :can_admin_label, -> { Ability.allowed?(current_user, :can_admin_label, group) }, milestone: '17.5'
    provide :can_create_epic, -> { Ability.allowed?(current_user, :can_create_epic, group) }, milestone: '17.5'
  end
end
