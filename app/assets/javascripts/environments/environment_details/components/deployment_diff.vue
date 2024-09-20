<script>
import { GlTruncate, GlLink, GlBadge } from '@gitlab/ui';

export default {
  components: {
    GlBadge,
    GlTruncate,
    GlLink,
  },
  props: {
    item: {
      type: Object,
      required: false,
      default: null,
    },
    items: {
      type: Array,
      required: false,
      default: null,
    }
  },
  methods: {
    previousSuccessfulDeployment() {

    }
  }
};
</script>
<template>
  <gl-link v-if="item" :href="job.webPath">
    <gl-truncate :text="item.commit.id" />
  </gl-link>
<!--  <gl-badge v-else variant="info">{{ __('API') }}</gl-badge>-->
</template>
