<script>
import { GlLink } from '@gitlab/ui';
import { sprintf } from '~/locale';
import { HELP_LINK_ARIA_LABEL } from '~/usage_quotas/storage/constants';
import HelpIcon from '~/vue_shared/components/help_icon/help_icon.vue';

export default {
  name: 'StorageTypeHelpLink',
  components: {
    GlLink,
    HelpIcon,
  },
  props: {
    storageType: {
      type: String,
      required: true,
    },
    helpLinks: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ariaLabel() {
      return sprintf(HELP_LINK_ARIA_LABEL, {
        linkTitle: this.storageType,
      });
    },
  },
};
</script>

<template>
  <gl-link :href="helpLinks[storageType]" target="_blank" :aria-label="ariaLabel" class="gl-ml-3">
    <help-icon />
  </gl-link>
</template>
