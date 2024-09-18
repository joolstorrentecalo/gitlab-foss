<script>
import BoldText from '~/vue_merge_request_widget/components/bold_text.vue';
import { MERGE_ACTIVE_STATUS_PHRASES } from '../../constants';
import StatusIcon from '../mr_widget_status_icon.vue';

export default {
  name: 'MRWidgetMerging',
  components: {
    BoldText,
    StatusIcon,
  },
  props: {
    mr: {
      type: Object,
      required: true,
    },
    service: {
      type: Object,
      required: true,
    },
  },
  data() {
    const statusCount = MERGE_ACTIVE_STATUS_PHRASES.length;

    return {
      mergeStatus: MERGE_ACTIVE_STATUS_PHRASES[Math.floor(Math.random() * statusCount)],
    };
  },
};
</script>
<template>
  <div class="mr-widget-body mr-state-locked media">
    <status-icon status="loading" />
    <div class="media-body" data-testid="merging-state">
      <bold-text :message="mergeStatus.message" />
      <gl-emoji :data-name="mergeStatus.emoji" />
    </div>
  </div>
</template>
