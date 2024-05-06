# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Work item keyboard shortcuts', :js, feature_category: :team_planning do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be(:work_item) { create(:work_item, project: project) }
  let(:work_items_path) { project_work_item_path(project, work_item.iid) }

  context 'for signed in user' do
    before_all do
      project.add_developer(user)
    end

    before do
      sign_in(user)
      visit work_items_path

      wait_for_requests
    end

    describe 'sidebar' do
      it 'pressing m opens milestones dropdown for editing' do
        find('body').native.send_key('m')

        expect(find_by_testid('work-item-milestone-with-edit')).to have_selector('.gl-new-dropdown-panel')
      end

      it 'pressing l opens labels dropdown for editing' do
        find('body').native.send_key('l')

        expect(find_by_testid('work-item-labels-with-edit')).to have_selector('.gl-new-dropdown-panel')
      end

      it 'pressing a opens assignee dropdown for editing' do
        find('body').native.send_key('a')

        expect(find_by_testid('work-item-assignees-with-edit')).to have_selector('.gl-new-dropdown-panel')
      end

      it 'pressing e starts editing mode' do
        find('body').native.send_key('e')

        expect(page).to have_selector('[data-testid="work-item-title-with-edit"]')
        expect(page).to have_selector('form textarea#work-item-description')
      end
    end
  end
end
