import { GlLink, GlIcon, GlTooltip } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { workItemDevelopmentFeatureFlagNodes } from 'jest/work_items/mock_data';
import WorkItemDevelopmentFeatureFlags from '~/work_items/components/work_item_development/work_item_development_feature_flags.vue';

jest.mock('~/alert');

describe('WorkItemDevelopmentFeatureFlags', () => {
  let wrapper;

  const enabledFeatureFlag = workItemDevelopmentFeatureFlagNodes[0];
  const disabledFeatureFlag = workItemDevelopmentFeatureFlagNodes[1];

  const createComponent = ({ featureFlags = [enabledFeatureFlag] }) => {
    wrapper = shallowMount(WorkItemDevelopmentFeatureFlags, {
      propsData: {
        featureFlags,
      },
    });
  };

  const findFlagIcon = () => wrapper.findComponent(GlIcon);
  const findFlagLink = () => wrapper.findComponent(GlLink);
  const findFlagTooltip = () => wrapper.findComponent(GlTooltip);

  describe('Feature flag status icon', () => {
    it.each`
      state         | icon                       | featureFlag            | iconClass
      ${'Enabled'}  | ${'feature-flag'}          | ${enabledFeatureFlag}  | ${'gl-text-blue-500'}
      ${'Disabled'} | ${'feature-flag-disabled'} | ${disabledFeatureFlag} | ${'gl-text-gray-500'}
    `(
      'renders icon "$icon" when the state of the feature flag is "$state"',
      ({ icon, iconClass, featureFlag }) => {
        createComponent({ featureFlags: [featureFlag] });

        expect(findFlagIcon().props('name')).toBe(icon);
        expect(findFlagIcon().attributes('class')).toBe(iconClass);
      },
    );
  });

  describe('Feature flag link and name', () => {
    it('should render the flag path and name', () => {
      createComponent({ featureFlags: [enabledFeatureFlag] });

      expect(findFlagLink().attributes('href')).toBe(enabledFeatureFlag.path);
      expect(findFlagLink().attributes('href')).toContain(`/edit`);

      expect(findFlagLink().text()).toBe(enabledFeatureFlag.name);
    });
  });

  describe('Feature flag tooltip', () => {
    it('should render the tooltip with flag name, reference and "Enabled" copy if active', () => {
      createComponent({ featureFlags: [enabledFeatureFlag] });

      expect(findFlagTooltip().exists()).toBe(true);
      expect(findFlagTooltip().text()).toBe(
        `Feature flag  ${enabledFeatureFlag.name} ${enabledFeatureFlag.reference} Enabled`,
      );
    });

    it('should render the tooltip with flag name, reference and "Disabled" copy if not active', () => {
      createComponent({ featureFlags: [disabledFeatureFlag] });

      expect(findFlagTooltip().exists()).toBe(true);
      expect(findFlagTooltip().text()).toBe(
        `Feature flag  ${disabledFeatureFlag.name} ${disabledFeatureFlag.reference} Disabled`,
      );
    });
  });
});
