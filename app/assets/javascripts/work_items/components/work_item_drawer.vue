<script>
import { GlLink, GlDrawer, GlButton, GlTooltipDirective } from '@gitlab/ui';
import { escapeRegExp } from 'lodash';
import { __ } from '~/locale';
import deleteWorkItemMutation from '~/work_items/graphql/delete_work_item.mutation.graphql';
import workItemByIidQuery from '~/work_items/graphql/work_item_by_iid.query.graphql';
import { TYPE_EPIC, TYPE_ISSUE } from '~/issues/constants';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { visitUrl, setUrlParams, updateHistory, removeParams } from '~/lib/utils/url_utility';
import { getIdFromGraphQLId } from '../../graphql_shared/utils';

export default {
  name: 'WorkItemDrawer',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlLink,
    GlDrawer,
    GlButton,
    WorkItemDetail: () => import('~/work_items/components/work_item_detail.vue'),
  },
  inject: ['fullPath'],
  inheritAttrs: false,
  props: {
    open: {
      type: Boolean,
      required: true,
    },
    /**
     * @type {{ iid?: string, fullPath?: string, id?: string }}
     */
    activeItem: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    issuableType: {
      type: String,
      required: false,
      default: TYPE_ISSUE,
    },
  },
  data() {
    return {
      copyTooltipText: this.$options.i18n.copyTooltipText,
      workItem: {},
    };
  },
  apollo: {
    workItem: {
      query() {
        return workItemByIidQuery;
      },
      variables() {
        return {
          fullPath: this.activeItemFullPath,
          iid: this.activeItem.iid,
        };
      },
      skip() {
        return !this.activeItem?.iid || !this.activeItemFullPath || !this.open;
      },
      update(data) {
        return data.workspace.workItem ?? {};
      },
    },
  },
  computed: {
    activeItemFullPath() {
      if (this.activeItem?.fullPath) {
        return this.activeItem.fullPath;
      }
      return this.fullPath;
    },
    modalIsGroup() {
      return this.issuableType.toLowerCase() === TYPE_EPIC;
    },
    headerReference() {
      const path = this.activeItemFullPath.substring(this.activeItemFullPath.lastIndexOf('/') + 1);
      return `${path}#${this.activeItem.iid}`;
    },
  },
  watch: {
    activeItem: {
      deep: true,
      handler(newValue) {
        if (newValue?.iid) {
          this.setDrawerParams();
        }
      },
    },
  },
  methods: {
    async deleteWorkItem({ workItemId }) {
      try {
        const { data } = await this.$apollo.mutate({
          mutation: deleteWorkItemMutation,
          variables: { input: { id: workItemId } },
        });
        if (data.workItemDelete.errors?.length) {
          throw new Error(data.workItemDelete.errors[0]);
        }
        this.$emit('workItemDeleted');
      } catch (error) {
        this.$emit('deleteWorkItemError');
        Sentry.captureException(error);
      }
    },
    redirectToWorkItem(e) {
      const workItem = this.activeItem;
      if (e.metaKey || e.ctrlKey) {
        return;
      }
      e.preventDefault();
      const escapedFullPath = escapeRegExp(this.fullPath);
      // eslint-disable-next-line no-useless-escape
      const regex = new RegExp(`groups\/${escapedFullPath}\/-\/(work_items|epics)\/\\d+`);
      const isWorkItemPath = regex.test(workItem.webUrl);

      if (isWorkItemPath) {
        this.$router.push({
          name: 'workItem',
          params: {
            iid: workItem.iid,
          },
        });
      } else {
        visitUrl(workItem.webUrl);
      }
    },
    handleCopyToClipboard() {
      this.copyTooltipText = this.$options.i18n.copiedTooltipText;
      setTimeout(() => {
        this.copyTooltipText = this.$options.i18n.copyTooltipText;
      }, 2000);
    },
    setDrawerParams() {
      // since legacy epics don't have GID matching the work item ID, we need additional parameters
      const params = {
        iid: this.activeItem.iid,
        full_path: this.activeItemFullPath,
        id: getIdFromGraphQLId(this.activeItem.id),
      };
      updateHistory({
        // we're using `show` to match the modal view parameter
        url: setUrlParams({ show: btoa(JSON.stringify(params)) }),
      });
    },
    handleClose() {
      updateHistory({ url: removeParams(['show']) });
      this.$emit('close');
    },
  },
  i18n: {
    copyTooltipText: __('Copy item URL'),
    copiedTooltipText: __('Copied'),
    openTooltipText: __('Open in full page'),
  },
};
</script>

<template>
  <gl-drawer
    :open="open"
    data-testid="work-item-drawer"
    header-sticky
    header-height="calc(var(--top-bar-height) + var(--performance-bar-height))"
    class="gl-w-full gl-leading-reset lg:gl-w-[480px] xl:gl-w-[768px] min-[1440px]:gl-w-[912px]"
    @close="handleClose"
  >
    <template #title>
      <div class="gl-text gl-flex gl-w-full gl-items-center gl-gap-x-2 xl:gl-px-4">
        <gl-link
          :href="activeItem.webUrl"
          class="gl-text-sm gl-font-bold gl-text-default"
          @click="redirectToWorkItem"
        >
          {{ headerReference }}
        </gl-link>
        <gl-button
          v-gl-tooltip
          data-testid="work-item-drawer-copy-button"
          :title="copyTooltipText"
          category="tertiary"
          class="gl-text-secondary"
          icon="link"
          size="small"
          :aria-label="$options.i18n.copyTooltipText"
          :data-clipboard-text="activeItem.webUrl"
          @click="handleCopyToClipboard"
        />
        <gl-button
          v-gl-tooltip
          data-testid="work-item-drawer-link-button"
          :href="activeItem.webUrl"
          :title="$options.i18n.openTooltipText"
          category="tertiary"
          class="gl-text-secondary"
          icon="maximize"
          size="small"
          :aria-label="$options.i18n.openTooltipText"
          @click="redirectToWorkItem"
        />
      </div>
    </template>
    <template #default>
      <work-item-detail
        :key="workItem.iid"
        :work-item-iid="workItem.iid"
        :modal-work-item-full-path="activeItemFullPath"
        :modal-is-group="modalIsGroup"
        is-drawer
        class="work-item-drawer !gl-pt-0 xl:!gl-px-6"
        @deleteWorkItem="deleteWorkItem"
        v-on="$listeners"
      />
    </template>
  </gl-drawer>
</template>
