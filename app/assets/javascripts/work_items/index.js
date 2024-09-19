import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { DESIGN_MARK_APP_START, DESIGN_MEASURE_BEFORE_APP } from '~/performance/constants';
import { performanceMarkAndMeasure } from '~/performance/utils';
import { WORKSPACE_GROUP } from '~/issues/constants';
import { addShortcutsExtension } from '~/behaviors/shortcuts';
import ShortcutsWorkItems from '~/behaviors/shortcuts/shortcuts_work_items';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import { injectVueAppBreadcrumbs } from '~/lib/utils/breadcrumbs';
import { apolloProvider } from '~/graphql_shared/issuable_client';
import { __ } from '~/locale';
import App from './components/app.vue';
import WorkItemBreadcrumb from './components/work_item_breadcrumb.vue';
import bootWorkItemClient from './graphql/boot_work_item_details.query.graphql';
import activeDiscussionQuery from './components/design_management/graphql/client/active_design_discussion.query.graphql';
import { createRouter } from './router';

Vue.use(VueApollo);

export const initWorkItemsRoot = async ({ workItemType, workspaceType } = {}) => {
  const el = document.querySelector('#js-work-items');

  if (!el) {
    return undefined;
  }

  const defaultClient = createDefaultClient();

  const {
    data: { clientProvider },
  } = await defaultClient.query({
    query: bootWorkItemClient,
    variables: { fullPath: 'flightjs' },
  });

  addShortcutsExtension(ShortcutsNavigation);
  addShortcutsExtension(ShortcutsWorkItems);

  const { fullPath, iid, workItemType: listWorkItemType } = el.dataset;

  const isGroup = workspaceType === WORKSPACE_GROUP;
  const router = createRouter({
    fullPath,
    workItemType,
    workspaceType,
    defaultBranch: clientProvider.defaultBranch,
    isGroup,
  });
  let listPath = clientProvider.paths.issuesListPath;

  if (isGroup) {
    listPath = clientProvider.paths.epicsListPath;
    injectVueAppBreadcrumbs(router, WorkItemBreadcrumb, apolloProvider, {
      workItemType: listWorkItemType,
      epicsListPath: clientProvider.paths.epicsListPath,
    });
  }

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: activeDiscussionQuery,
    data: {
      activeDesignDiscussion: {
        __typename: 'ActiveDesignDiscussion',
        id: null,
        source: null,
      },
    },
  });

  if (gon.features.workItemsViewPreference) {
    import(/* webpackChunkName: 'work_items_feedback' */ '~/work_items_feedback')
      .then(({ initWorkItemsFeedback }) => {
        initWorkItemsFeedback();
      })
      .catch({});
  }

  return new Vue({
    el,
    name: 'WorkItemsRoot',
    router,
    apolloProvider,
    provide: {
      fullPath,
      isGroup,
      issuesListPath: listPath,
      initialSort: clientProvider.issueInitialSort,
      workItemType: listWorkItemType,
      isSignedIn: clientProvider.isSignedIn,
      ...clientProvider.features,
      ...clientProvider.paths,
      ...clientProvider.permissions,
      newCommentTemplatePaths: {
        text: __('Your comment templates'),
        href: clientProvider.paths.newCommentTemplatePaths,
      },
    },
    mounted() {
      performanceMarkAndMeasure({
        mark: DESIGN_MARK_APP_START,
        measures: [
          {
            name: DESIGN_MEASURE_BEFORE_APP,
          },
        ],
      });
    },
    render(createElement) {
      return createElement(App, {
        props: {
          iid: isGroup ? iid : undefined,
        },
      });
    },
  });
};
