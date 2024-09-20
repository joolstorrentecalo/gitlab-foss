<script>
import { GlIcon, GlTooltip, GlLink } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlIcon,
    GlTooltip,
    GlLink,
  },
  props: {
    featureFlags: {
      type: [Object],
      required: true,
    },
  },
  computed: {
    sortedFeatureFlags() {
      const sortedByRelationshipDate = [...this.featureFlags].reverse();
      const enabledFlags = sortedByRelationshipDate.filter((flag) => flag.active);
      const disabledFlags = sortedByRelationshipDate.filter((flag) => !flag.active);

      return [...enabledFlags, ...disabledFlags];
    },
  },
  methods: {
    icon({ active }) {
      return active ? 'feature-flag' : 'feature-flag-disabled';
    },
    iconColor({ active }) {
      return active ? 'gl-text-blue-500' : 'gl-text-gray-500';
    },
    flagStatus(flag) {
      return flag.active ? __('Enabled') : __('Disabled');
    },
    addBottomMargin(index) {
      return index + 1 < this.sortedFeatureFlags.length ? 'gl-mb-2' : '';
    },
  },
};
</script>

<template>
  <div class="gl-mb-2">
    <ul class="content-list">
      <li
        v-for="(flag, i) in sortedFeatureFlags"
        :key="flag.id"
        class="!gl-border-b-0 !gl-p-0"
        data-test-id="work-item-dev-feature-flag"
      >
        <div
          ref="flagInfo"
          class="gl-grid-cols-[auto, 1fr] gl-grid gl-w-fit gl-gap-2 gl-gap-5 gl-p-2 gl-pl-0 gl-pr-3"
          :class="addBottomMargin(i)"
        >
          <gl-link
            :href="flag.path"
            class="gl-truncate gl-text-gray-900 hover:gl-text-gray-900 hover:gl-underline"
          >
            <gl-icon :name="icon(flag)" :class="iconColor(flag)" />
            {{ flag.name }}
          </gl-link>
          <gl-tooltip :target="() => $refs.flagInfo[i]" placement="top">
            <span class="gl-inline-block gl-font-bold"> {{ __('Feature flag') }} </span>
            <span class="gl-inline-block">{{ flag.name }} {{ flag.reference }}</span>
            <span class="gl-inline-block gl-text-gray-500">{{ flagStatus(flag) }}</span>
          </gl-tooltip>
        </div>
      </li>
    </ul>
  </div>
</template>
