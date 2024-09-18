import { shallowMount } from '@vue/test-utils';
import MrWidgetMerging from '~/vue_merge_request_widget/components/states/mr_widget_merging.vue';
import BoldText from '~/vue_merge_request_widget/components/bold_text.vue';

describe('MRWidgetMerging', () => {
  let wrapper;

  const GlEmoji = { template: '<img />' };
  const createComponent = () => {
    wrapper = shallowMount(MrWidgetMerging, {
      propsData: {
        mr: {
          targetBranchPath: '/branch-path',
          targetBranch: 'branch',
          transitionStateMachine() {},
        },
        service: {},
      },
      stubs: {
        GlEmoji,
      },
    });
  };

  it('renders information about merge request being merged', () => {
    createComponent();

    const message = wrapper.findComponent(BoldText).props('message');
    expect(message).toContain('Merging!');
  });
});
