import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlLoadingIcon } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { mockTracking, triggerEvent } from 'helpers/tracking_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import Component from '~/sidebar/components/reviewers/reviewer_title.vue';
import getMergeRequestReviewers from '~/sidebar/queries/get_merge_request_reviewers.query.graphql';
import userPermissionsQuery from '~/merge_requests/components/reviewers/queries/user_permissions.query.graphql';

Vue.use(VueApollo);

describe('ReviewerTitle component', () => {
  let wrapper;

  const findEditButton = () => wrapper.findByTestId('reviewers-edit-button');

  const createComponent = (props, { reviewerAssignDrawer = false } = {}) => {
    const apolloProvider = createMockApollo([
      [getMergeRequestReviewers, jest.fn().mockResolvedValue({ data: { workspace: null } })],
      [userPermissionsQuery, jest.fn().mockResolvedValue({ data: { project: null } })],
    ]);

    return mountExtended(Component, {
      apolloProvider,
      propsData: {
        numberOfReviewers: 0,
        editable: false,
        ...props,
      },
      provide: {
        projectPath: 'gitlab-org/gitlab',
        issuableId: '1',
        issuableIid: '1',
        multipleApprovalRulesAvailable: false,
        glFeatures: {
          reviewerAssignDrawer,
        },
      },
      stubs: ['approval-summary', 'ReviewerDropdown'],
    });
  };

  describe('reviewer title', () => {
    it('renders reviewer', () => {
      wrapper = createComponent({
        numberOfReviewers: 1,
        editable: false,
      });

      expect(wrapper.vm.$el.innerText.trim()).toEqual('Reviewer');
    });

    it('renders 2 reviewers', () => {
      wrapper = createComponent({
        numberOfReviewers: 2,
        editable: false,
      });

      expect(wrapper.vm.$el.innerText.trim()).toEqual('2 Reviewers');
    });
  });

  it('does not render spinner by default', () => {
    wrapper = createComponent({
      numberOfReviewers: 0,
      editable: false,
    });

    expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(false);
  });

  it('renders spinner when loading', () => {
    wrapper = createComponent({
      loading: true,
      numberOfReviewers: 0,
      editable: false,
    });

    expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
  });

  it('does not render edit link when not editable', () => {
    wrapper = createComponent({
      numberOfReviewers: 0,
      editable: false,
    });

    expect(findEditButton().exists()).toBe(false);
  });

  it('renders edit link when editable', () => {
    wrapper = createComponent({
      numberOfReviewers: 0,
      editable: true,
    });

    expect(findEditButton().exists()).toBe(true);
  });

  it('tracks the event when edit is clicked', () => {
    wrapper = createComponent({
      numberOfReviewers: 0,
      editable: true,
    });

    const spy = mockTracking('_category_', wrapper.element, jest.spyOn);
    triggerEvent('.js-sidebar-dropdown-toggle');

    expect(spy).toHaveBeenCalledWith('_category_', 'click_edit_button', {
      label: 'right_sidebar',
      property: 'reviewer',
    });
  });

  it('sets title for dropdown toggle as `Change reviewer`', () => {
    wrapper = createComponent(
      {
        editable: true,
      },
      { reviewerAssignDrawer: false },
    );

    expect(findEditButton().attributes('title')).toBe('Change reviewer');
  });
});
