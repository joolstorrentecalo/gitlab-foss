# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Delete protected tag', :js, feature_category: :source_code_management do
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }
  let(:tag_name) { 'v1.1.1' }

  let_it_be(:owner) { create(:user) }
  let_it_be(:maintainer) { create(:user) }

  before do
    project.add_owner(owner)
    project.add_maintainer(maintainer)

    sign_in(user)
    create(:protected_tag, project: project, name: tag_name)
    visit project_tags_path(project)
  end

  context 'when visits from the tags list page' do
    context 'when owner' do
      let(:user) { owner }

      it 'deletes the tag' do
        expect(page).to have_content "#{tag_name} protected"

        within_testid('tag-row', text: tag_name) do
          click_button('Delete tag')
        end

        assert_modal_content(tag_name)
        confirm_delete_tag(tag_name)

        expect(page).not_to have_content tag_name
      end
    end

    context 'when maintainer' do
      let(:user) { maintainer }

      it 'can not delete protected tags' do
        expect(page).to have_content 'v1.1.1'

        container = find_by_testid('tag-row', text: 'v1.1.1')
        expect(container).to have_button('Only a project owner can delete a protected tag',
          disabled: true)
      end
    end
  end

  context 'when visits from a specific tag page' do
    before do
      click_on tag_name
    end

    context 'when owner' do
      let(:user) { owner }

      it 'deletes the tag' do
        expect(page).to have_current_path(project_tag_path(project, tag_name), ignore_query: true)

        click_button('Delete tag')
        assert_modal_content(tag_name)
        confirm_delete_tag(tag_name)

        expect(page).to have_current_path(project_tags_path(project), ignore_query: true)
        expect(page).not_to have_content tag_name
      end
    end

    context 'when maintainer' do
      let(:user) { maintainer }

      it 'can not delete protected tags' do
        expect(page).to have_content 'v1.1.1'

        expect(page).to have_button('Only a project owner can delete a protected tag',
          disabled: true)
      end
    end
  end

  def assert_modal_content(tag_name)
    within '.modal' do
      expect(page).to have_content("Please type the following to confirm: #{tag_name}")
      expect(page).to have_field('delete_tag_input')
      expect(page).to have_button('Yes, delete protected tag', disabled: true)
    end
  end

  def confirm_delete_tag(tag_name)
    within '.modal' do
      fill_in('delete_tag_input', with: tag_name)
      click_button('Yes, delete protected tag')
      wait_for_requests
    end
  end
end
