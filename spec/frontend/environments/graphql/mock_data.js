export const rolloutStatus = {
  instances: [
    {
      status: 'succeeded',
      tooltip: 'tanuki-2334 Finished',
      podName: 'production-tanuki-1',
      stable: false,
    },
    {
      status: 'succeeded',
      tooltip: 'tanuki-2335 Finished',
      podName: 'production-tanuki-1',
      stable: false,
    },
    {
      status: 'succeeded',
      tooltip: 'tanuki-2336 Finished',
      podName: 'production-tanuki-1',
      stable: false,
    },
    {
      status: 'succeeded',
      tooltip: 'tanuki-2337 Finished',
      podName: 'production-tanuki-1',
      stable: false,
    },
    {
      status: 'succeeded',
      tooltip: 'tanuki-2338 Finished',
      podName: 'production-tanuki-1',
      stable: false,
    },
    {
      status: 'succeeded',
      tooltip: 'tanuki-2339 Finished',
      podName: 'production-tanuki-1',
      stable: false,
    },
    { status: 'succeeded', tooltip: 'tanuki-2340 Finished', podName: 'production-tanuki-1' },
    { status: 'succeeded', tooltip: 'tanuki-2334 Finished', podName: 'production-tanuki-1' },
    { status: 'succeeded', tooltip: 'tanuki-2335 Finished', podName: 'production-tanuki-1' },
    { status: 'succeeded', tooltip: 'tanuki-2336 Finished', podName: 'production-tanuki-1' },
    { status: 'succeeded', tooltip: 'tanuki-2337 Finished', podName: 'production-tanuki-1' },
    { status: 'succeeded', tooltip: 'tanuki-2338 Finished', podName: 'production-tanuki-1' },
    { status: 'succeeded', tooltip: 'tanuki-2339 Finished', podName: 'production-tanuki-1' },
    { status: 'succeeded', tooltip: 'tanuki-2340 Finished', podName: 'production-tanuki-1' },
    { status: 'running', tooltip: 'tanuki-2341 Deploying', podName: 'production-tanuki-1' },
    { status: 'running', tooltip: 'tanuki-2342 Deploying', podName: 'production-tanuki-1' },
    { status: 'running', tooltip: 'tanuki-2343 Deploying', podName: 'production-tanuki-1' },
    { status: 'failed', tooltip: 'tanuki-2344 Failed', podName: 'production-tanuki-1' },
    { status: 'unknown', tooltip: 'tanuki-2345 Ready', podName: 'production-tanuki-1' },
    { status: 'unknown', tooltip: 'tanuki-2346 Ready', podName: 'production-tanuki-1' },
    { status: 'pending', tooltip: 'tanuki-2348 Preparing', podName: 'production-tanuki-1' },
    { status: 'pending', tooltip: 'tanuki-2349 Preparing', podName: 'production-tanuki-1' },
    { status: 'pending', tooltip: 'tanuki-2350 Preparing', podName: 'production-tanuki-1' },
    { status: 'pending', tooltip: 'tanuki-2353 Preparing', podName: 'production-tanuki-1' },
    { status: 'pending', tooltip: 'tanuki-2354 waiting', podName: 'production-tanuki-1' },
    { status: 'pending', tooltip: 'tanuki-2355 waiting', podName: 'production-tanuki-1' },
    { status: 'pending', tooltip: 'tanuki-2356 waiting', podName: 'production-tanuki-1' },
  ],
  abortUrl: 'url',
  rollbackUrl: 'url',
  completion: 100,
  status: 'found',
  canaryIngress: { canaryWeight: 50 },
};
export const environmentsApp = {
  environments: [
    {
      name: 'review',
      size: 2,
      latest: {
        id: 42,
        global_id: 'gid://gitlab/Environment/42',
        name: 'review/goodbye',
        state: 'available',
        external_url: 'https://example.org',
        environment_type: 'review',
        name_without_type: 'goodbye',
        last_deployment: null,
        has_stop_action: false,
        rollout_status: null,
        environment_path: '/h5bp/html5-boilerplate/-/environments/42',
        stop_path: '/h5bp/html5-boilerplate/-/environments/42/stop',
        cancel_auto_stop_path: '/h5bp/html5-boilerplate/-/environments/42/cancel_auto_stop',
        delete_path: '/api/v4/projects/8/environments/42',
        folder_path: '/h5bp/html5-boilerplate/-/environments/folders/review',
        created_at: '2021-10-04T19:27:20.639Z',
        updated_at: '2021-10-04T19:27:20.639Z',
        can_stop: true,
        logs_path: '/h5bp/html5-boilerplate/-/logs?environment_name=review%2Fgoodbye',
        logs_api_path: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=review%2Fgoodbye',
        enable_advanced_logs_querying: false,
        can_delete: false,
        has_opened_alert: false,
      },
    },
    {
      name: 'production',
      size: 1,
      latest: {
        id: 8,
        global_id: 'gid://gitlab/Environment/8',
        name: 'production',
        state: 'available',
        external_url: 'https://example.org',
        environment_type: null,
        name_without_type: 'production',
        last_deployment: {
          id: 80,
          iid: 24,
          sha: '4ca0310329e8f251b892d7be205eec8b7dd220e5',
          ref: {
            name: 'root-master-patch-18104',
            ref_path: '/h5bp/html5-boilerplate/-/tree/root-master-patch-18104',
          },
          status: 'success',
          created_at: '2021-10-08T19:53:54.543Z',
          deployed_at: '2021-10-08T20:02:36.763Z',
          tag: false,
          'last?': true,
          user: {
            id: 1,
            name: 'Administrator',
            username: 'root',
            state: 'active',
            avatar_url:
              'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
            web_url: 'http://gdk.test:3000/root',
            show_status: false,
            path: '/root',
          },
          deployable: {
            id: 911,
            name: 'deploy-job',
            started: '2021-10-08T19:54:00.658Z',
            complete: true,
            archived: false,
            build_path: '/h5bp/html5-boilerplate/-/jobs/911',
            retry_path: '/h5bp/html5-boilerplate/-/jobs/911/retry',
            play_path: '/h5bp/html5-boilerplate/-/jobs/911/play',
            playable: true,
            scheduled: false,
            created_at: '2021-10-08T19:53:54.482Z',
            updated_at: '2021-10-08T20:02:36.730Z',
            status: {
              icon: 'status_success',
              text: 'passed',
              label: 'manual play action',
              group: 'success',
              tooltip: 'passed',
              has_details: true,
              details_path: '/h5bp/html5-boilerplate/-/jobs/911',
              illustration: {
                image:
                  '/assets/illustrations/empty-state/empty-job-manual-md-c55aee2c5f9ebe9f72751480af8bb307be1a6f35552f344cc6d1bf979d3422f6.svg',
                size: '',
                title: 'This job requires a manual action',
                content:
                  'This job requires manual intervention to start. Before starting this job, you can add variables below for last-minute configuration changes.',
              },
              favicon:
                '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
              action: {
                icon: 'play',
                title: 'Play',
                path: '/h5bp/html5-boilerplate/-/jobs/911/play',
                method: 'post',
                button_title: 'Run job',
              },
            },
          },
          commit: {
            id: '4ca0310329e8f251b892d7be205eec8b7dd220e5',
            short_id: '4ca03103',
            created_at: '2021-10-08T19:27:01.000+00:00',
            parent_ids: ['b385360b15bd61391a0efbd101788d4a80387270'],
            title: 'Update .gitlab-ci.yml',
            message: 'Update .gitlab-ci.yml',
            author_name: 'Administrator',
            author_email: 'admin@example.com',
            authored_date: '2021-10-08T19:27:01.000+00:00',
            committer_name: 'Administrator',
            committer_email: 'admin@example.com',
            committed_date: '2021-10-08T19:27:01.000+00:00',
            trailers: {},
            web_url:
              'http://gdk.test:3000/h5bp/html5-boilerplate/-/commit/4ca0310329e8f251b892d7be205eec8b7dd220e5',
            author: {
              id: 1,
              name: 'Administrator',
              username: 'root',
              state: 'active',
              avatar_url:
                'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
              web_url: 'http://gdk.test:3000/root',
              show_status: false,
              path: '/root',
            },
            author_gravatar_url:
              'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
            commit_url:
              'http://gdk.test:3000/h5bp/html5-boilerplate/-/commit/4ca0310329e8f251b892d7be205eec8b7dd220e5',
            commit_path:
              '/h5bp/html5-boilerplate/-/commit/4ca0310329e8f251b892d7be205eec8b7dd220e5',
          },
          manual_actions: [],
          scheduled_actions: [],
          playable_build: {
            retry_path: '/h5bp/html5-boilerplate/-/jobs/911/retry',
            play_path: '/h5bp/html5-boilerplate/-/jobs/911/play',
          },
          cluster: null,
        },
        has_stop_action: false,
        rollout_status: null,
        environment_path: '/h5bp/html5-boilerplate/-/environments/8',
        stop_path: '/h5bp/html5-boilerplate/-/environments/8/stop',
        cancel_auto_stop_path: '/h5bp/html5-boilerplate/-/environments/8/cancel_auto_stop',
        delete_path: '/api/v4/projects/8/environments/8',
        folder_path: '/h5bp/html5-boilerplate/-/environments/folders/production',
        created_at: '2021-06-17T15:09:38.599Z',
        updated_at: '2021-10-08T19:50:44.445Z',
        can_stop: true,
        logs_path: '/h5bp/html5-boilerplate/-/logs?environment_name=production',
        logs_api_path: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=production',
        enable_advanced_logs_querying: false,
        can_delete: false,
        has_opened_alert: false,
      },
    },
    {
      name: 'staging',
      size: 1,
      latest: {
        id: 7,
        global_id: 'gid://gitlab/Environment/7',
        name: 'staging',
        state: 'available',
        external_url: null,
        environment_type: null,
        name_without_type: 'staging',
        last_deployment: null,
        has_stop_action: false,
        rollout_status: null,
        environment_path: '/h5bp/html5-boilerplate/-/environments/7',
        stop_path: '/h5bp/html5-boilerplate/-/environments/7/stop',
        cancel_auto_stop_path: '/h5bp/html5-boilerplate/-/environments/7/cancel_auto_stop',
        delete_path: '/api/v4/projects/8/environments/7',
        folder_path: '/h5bp/html5-boilerplate/-/environments/folders/staging',
        created_at: '2021-06-17T15:09:38.570Z',
        updated_at: '2021-06-17T15:09:38.570Z',
        can_stop: true,
        logs_path: '/h5bp/html5-boilerplate/-/logs?environment_name=staging',
        logs_api_path: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=staging',
        enable_advanced_logs_querying: false,
        can_delete: false,
        has_opened_alert: false,
      },
    },
  ],
  review_app: {
    can_setup_review_app: true,
    all_clusters_empty: true,
    has_review_app: false,
    review_snippet:
      '{"deploy_review"=>{"stage"=>"deploy", "script"=>["echo \\"Deploy a review app\\""], "environment"=>{"name"=>"review/$CI_COMMIT_REF_NAME", "url"=>"https://$CI_ENVIRONMENT_SLUG.example.com"}, "only"=>["branches"]}}',
  },
  can_stop_stale_environments: true,
  active_count: 4,
  stopped_count: 0,
};

export const resolvedEnvironmentsApp = {
  activeCount: 4,
  environments: [
    {
      name: 'review',
      size: 2,
      latest: {
        id: 42,
        globalId: 'gid://gitlab/Environment/42',
        name: 'review/goodbye',
        state: 'available',
        externalUrl: 'https://example.org',
        environmentType: 'review',
        nameWithoutType: 'goodbye',
        lastDeployment: null,
        hasStopAction: false,
        rolloutStatus: null,
        environmentPath: '/h5bp/html5-boilerplate/-/environments/42',
        stopPath: '/h5bp/html5-boilerplate/-/environments/42/stop',
        cancelAutoStopPath: '/h5bp/html5-boilerplate/-/environments/42/cancel_auto_stop',
        deletePath: '/api/v4/projects/8/environments/42',
        folderPath: '/h5bp/html5-boilerplate/-/environments/folders/review',
        createdAt: '2021-10-04T19:27:20.639Z',
        updatedAt: '2021-10-04T19:27:20.639Z',
        canStop: true,
        logsPath: '/h5bp/html5-boilerplate/-/logs?environment_name=review%2Fgoodbye',
        logsApiPath: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=review%2Fgoodbye',
        enableAdvancedLogsQuerying: false,
        canDelete: false,
        hasOpenedAlert: false,
      },
      __typename: 'NestedLocalEnvironment',
    },
    {
      name: 'production',
      size: 1,
      latest: {
        id: 8,
        globalId: 'gid://gitlab/Environment/8',
        name: 'production',
        state: 'available',
        externalUrl: 'https://example.org',
        environmentType: null,
        nameWithoutType: 'production',
        lastDeployment: {
          id: 80,
          iid: 24,
          sha: '4ca0310329e8f251b892d7be205eec8b7dd220e5',
          ref: {
            name: 'root-master-patch-18104',
            refPath: '/h5bp/html5-boilerplate/-/tree/root-master-patch-18104',
          },
          status: 'success',
          createdAt: '2021-10-08T19:53:54.543Z',
          deployedAt: '2021-10-08T20:02:36.763Z',
          tag: false,
          'last?': true,
          user: {
            id: 1,
            name: 'Administrator',
            username: 'root',
            state: 'active',
            avatarUrl:
              'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
            webUrl: 'http://gdk.test:3000/root',
            showStatus: false,
            path: '/root',
          },
          deployable: {
            id: 911,
            name: 'deploy-job',
            started: '2021-10-08T19:54:00.658Z',
            complete: true,
            archived: false,
            buildPath: '/h5bp/html5-boilerplate/-/jobs/911',
            retryPath: '/h5bp/html5-boilerplate/-/jobs/911/retry',
            playPath: '/h5bp/html5-boilerplate/-/jobs/911/play',
            playable: true,
            scheduled: false,
            createdAt: '2021-10-08T19:53:54.482Z',
            updatedAt: '2021-10-08T20:02:36.730Z',
            status: {
              icon: 'status_success',
              text: 'passed',
              label: 'manual play action',
              group: 'success',
              tooltip: 'passed',
              hasDetails: true,
              detailsPath: '/h5bp/html5-boilerplate/-/jobs/911',
              illustration: {
                image:
                  '/assets/illustrations/empty-state/empty-job-manual-md-c55aee2c5f9ebe9f72751480af8bb307be1a6f35552f344cc6d1bf979d3422f6.svg',
                size: '',
                title: 'This job requires a manual action',
                content:
                  'This job requires manual intervention to start. Before starting this job, you can add variables below for last-minute configuration changes.',
              },
              favicon:
                '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
              action: {
                icon: 'play',
                title: 'Play',
                path: '/h5bp/html5-boilerplate/-/jobs/911/play',
                method: 'post',
                buttonTitle: 'Run job',
              },
            },
          },
          commit: {
            id: '4ca0310329e8f251b892d7be205eec8b7dd220e5',
            shortId: '4ca03103',
            createdAt: '2021-10-08T19:27:01.000+00:00',
            parentIds: ['b385360b15bd61391a0efbd101788d4a80387270'],
            title: 'Update .gitlab-ci.yml',
            message: 'Update .gitlab-ci.yml',
            authorName: 'Administrator',
            authorEmail: 'admin@example.com',
            authoredDate: '2021-10-08T19:27:01.000+00:00',
            committerName: 'Administrator',
            committerEmail: 'admin@example.com',
            committedDate: '2021-10-08T19:27:01.000+00:00',
            trailers: {},
            webUrl:
              'http://gdk.test:3000/h5bp/html5-boilerplate/-/commit/4ca0310329e8f251b892d7be205eec8b7dd220e5',
            author: {
              id: 1,
              name: 'Administrator',
              username: 'root',
              state: 'active',
              avatarUrl:
                'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
              webUrl: 'http://gdk.test:3000/root',
              showStatus: false,
              path: '/root',
            },
            authorGravatarUrl:
              'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
            commitUrl:
              'http://gdk.test:3000/h5bp/html5-boilerplate/-/commit/4ca0310329e8f251b892d7be205eec8b7dd220e5',
            commitPath: '/h5bp/html5-boilerplate/-/commit/4ca0310329e8f251b892d7be205eec8b7dd220e5',
          },
          manualActions: [],
          scheduledActions: [],
          playableBuild: {
            retryPath: '/h5bp/html5-boilerplate/-/jobs/911/retry',
            playPath: '/h5bp/html5-boilerplate/-/jobs/911/play',
          },
          cluster: null,
        },
        hasStopAction: false,
        rolloutStatus: null,
        environmentPath: '/h5bp/html5-boilerplate/-/environments/8',
        stopPath: '/h5bp/html5-boilerplate/-/environments/8/stop',
        cancelAutoStopPath: '/h5bp/html5-boilerplate/-/environments/8/cancel_auto_stop',
        deletePath: '/api/v4/projects/8/environments/8',
        folderPath: '/h5bp/html5-boilerplate/-/environments/folders/production',
        createdAt: '2021-06-17T15:09:38.599Z',
        updatedAt: '2021-10-08T19:50:44.445Z',
        canStop: true,
        logsPath: '/h5bp/html5-boilerplate/-/logs?environment_name=production',
        logsApiPath: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=production',
        enableAdvancedLogsQuerying: false,
        canDelete: false,
        hasOpenedAlert: false,
      },
      __typename: 'NestedLocalEnvironment',
    },
    {
      name: 'staging',
      size: 1,
      latest: {
        id: 7,
        globalId: 'gid://gitlab/Environment/7',
        name: 'staging',
        state: 'available',
        externalUrl: null,
        environmentType: null,
        nameWithoutType: 'staging',
        lastDeployment: null,
        hasStopAction: false,
        rolloutStatus: null,
        environmentPath: '/h5bp/html5-boilerplate/-/environments/7',
        stopPath: '/h5bp/html5-boilerplate/-/environments/7/stop',
        cancelAutoStopPath: '/h5bp/html5-boilerplate/-/environments/7/cancel_auto_stop',
        deletePath: '/api/v4/projects/8/environments/7',
        folderPath: '/h5bp/html5-boilerplate/-/environments/folders/staging',
        createdAt: '2021-06-17T15:09:38.570Z',
        updatedAt: '2021-06-17T15:09:38.570Z',
        canStop: true,
        logsPath: '/h5bp/html5-boilerplate/-/logs?environment_name=staging',
        logsApiPath: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=staging',
        enableAdvancedLogsQuerying: false,
        canDelete: false,
        hasOpenedAlert: false,
      },
      __typename: 'NestedLocalEnvironment',
    },
  ],
  reviewApp: {
    canSetupReviewApp: true,
    allClustersEmpty: true,
    hasReviewApp: false,
    reviewSnippet:
      '{"deploy_review"=>{"stage"=>"deploy", "script"=>["echo \\"Deploy a review app\\""], "environment"=>{"name"=>"review/$CI_COMMIT_REF_NAME", "url"=>"https://$CI_ENVIRONMENT_SLUG.example.com"}, "only"=>["branches"]}}',
    __typename: 'ReviewApp',
  },
  canStopStaleEnvironments: true,
  stoppedCount: 0,
  __typename: 'LocalEnvironmentApp',
};

export const folder = {
  environments: [
    {
      id: 42,
      global_id: 'gid://gitlab/Environment/42',
      name: 'review/goodbye',
      state: 'available',
      external_url: 'https://example.org',
      environment_type: 'review',
      name_without_type: 'goodbye',
      last_deployment: null,
      has_stop_action: false,
      rollout_status: null,
      environment_path: '/h5bp/html5-boilerplate/-/environments/42',
      stop_path: '/h5bp/html5-boilerplate/-/environments/42/stop',
      cancel_auto_stop_path: '/h5bp/html5-boilerplate/-/environments/42/cancel_auto_stop',
      delete_path: '/api/v4/projects/8/environments/42',
      folder_path: '/h5bp/html5-boilerplate/-/environments/folders/review',
      created_at: '2021-10-04T19:27:20.639Z',
      updated_at: '2021-10-04T19:27:20.639Z',
      can_stop: true,
      logs_path: '/h5bp/html5-boilerplate/-/logs?environment_name=review%2Fgoodbye',
      logs_api_path: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=review%2Fgoodbye',
      enable_advanced_logs_querying: false,
      can_delete: false,
      has_opened_alert: false,
    },
    {
      id: 41,
      global_id: 'gid://gitlab/Environment/41',
      name: 'review/hello',
      state: 'available',
      external_url: 'https://example.org',
      environment_type: 'review',
      name_without_type: 'hello',
      last_deployment: null,
      has_stop_action: false,
      rollout_status: null,
      environment_path: '/h5bp/html5-boilerplate/-/environments/41',
      stop_path: '/h5bp/html5-boilerplate/-/environments/41/stop',
      cancel_auto_stop_path: '/h5bp/html5-boilerplate/-/environments/41/cancel_auto_stop',
      delete_path: '/api/v4/projects/8/environments/41',
      folder_path: '/h5bp/html5-boilerplate/-/environments/folders/review',
      created_at: '2021-10-04T19:27:00.527Z',
      updated_at: '2021-10-04T19:27:00.527Z',
      can_stop: true,
      logs_path: '/h5bp/html5-boilerplate/-/logs?environment_name=review%2Fhello',
      logs_api_path: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=review%2Fhello',
      enable_advanced_logs_querying: false,
      can_delete: false,
      has_opened_alert: false,
    },
  ],
  active_count: 2,
  stopped_count: 0,
};

export const resolvedEnvironment = {
  id: 41,
  retryUrl: '/h5bp/html5-boilerplate/-/jobs/1014/retry',
  globalId: 'gid://gitlab/Environment/41',
  name: 'review/hello',
  state: 'available',
  externalUrl: 'https://example.org',
  environmentType: 'review',
  nameWithoutType: 'hello',
  tier: 'development',
  lastDeployment: {
    id: 78,
    iid: 24,
    sha: 'f3ba6dd84f8f891373e9b869135622b954852db1',
    ref: { name: 'main', refPath: '/h5bp/html5-boilerplate/-/tree/main' },
    status: 'success',
    createdAt: '2022-01-07T15:47:27.415Z',
    deployedAt: '2022-01-07T15:47:32.450Z',
    tierInYaml: 'staging',
    tag: false,
    isLast: true,
    user: {
      id: 1,
      username: 'root',
      name: 'Administrator',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://gck.test:3000/root',
      showStatus: false,
      path: '/root',
    },
    deployable: {
      id: 1014,
      name: 'deploy-prod',
      started: '2022-01-07T15:47:31.037Z',
      complete: true,
      archived: false,
      buildPath: '/h5bp/html5-boilerplate/-/jobs/1014',
      retryPath: '/h5bp/html5-boilerplate/-/jobs/1014/retry',
      playable: false,
      scheduled: false,
      createdAt: '2022-01-07T15:47:27.404Z',
      updatedAt: '2022-01-07T15:47:32.341Z',
      status: {
        icon: 'status_success',
        text: 'passed',
        label: 'passed',
        group: 'success',
        tooltip: 'passed',
        hasDetails: true,
        detailsPath: '/h5bp/html5-boilerplate/-/jobs/1014',
        illustration: {
          image:
            '/assets/illustrations/empty-state/empty-job-skipped-md-29a8a37d8a61d1b6f68cf3484f9024e53cd6eb95e28eae3554f8011a1146bf27.svg',
          size: '',
          title: 'This job does not have a trace.',
        },
        favicon:
          '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
        action: {
          icon: 'retry',
          title: 'Retry',
          path: '/h5bp/html5-boilerplate/-/jobs/1014/retry',
          method: 'post',
          buttonTitle: 'Retry this job',
        },
      },
    },
    commit: {
      id: 'f3ba6dd84f8f891373e9b869135622b954852db1',
      shortId: 'f3ba6dd8',
      createdAt: '2022-01-07T15:47:26.000+00:00',
      parentIds: ['3213b6ac17afab99be37d5d38f38c6c8407387cc'],
      title: 'Update .gitlab-ci.yml file',
      message: 'Update .gitlab-ci.yml file',
      authorName: 'Administrator',
      authorEmail: 'admin@example.com',
      authoredDate: '2022-01-07T15:47:26.000+00:00',
      committerName: 'Administrator',
      committerEmail: 'admin@example.com',
      committedDate: '2022-01-07T15:47:26.000+00:00',
      trailers: {},
      webUrl:
        'http://gck.test:3000/h5bp/html5-boilerplate/-/commit/f3ba6dd84f8f891373e9b869135622b954852db1',
      author: {
        id: 1,
        username: 'root',
        name: 'Administrator',
        state: 'active',
        avatarUrl:
          'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
        webUrl: 'http://gck.test:3000/root',
        showStatus: false,
        path: '/root',
      },
      authorGravatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      commitUrl:
        'http://gck.test:3000/h5bp/html5-boilerplate/-/commit/f3ba6dd84f8f891373e9b869135622b954852db1',
      commitPath: '/h5bp/html5-boilerplate/-/commit/f3ba6dd84f8f891373e9b869135622b954852db1',
    },
    manualActions: [
      {
        id: 1015,
        name: 'deploy-staging',
        started: null,
        complete: false,
        archived: false,
        buildPath: '/h5bp/html5-boilerplate/-/jobs/1015',
        playPath: '/h5bp/html5-boilerplate/-/jobs/1015/play',
        playable: true,
        scheduled: false,
        createdAt: '2022-01-07T15:47:27.422Z',
        updatedAt: '2022-01-07T15:47:28.557Z',
        status: {
          icon: 'status_manual',
          text: 'manual',
          label: 'manual play action',
          group: 'manual',
          tooltip: 'manual action',
          hasDetails: true,
          detailsPath: '/h5bp/html5-boilerplate/-/jobs/1015',
          illustration: {
            image:
              '/assets/illustrations/empty-state/empty-job-manual-md-c55aee2c5f9ebe9f72751480af8bb307be1a6f35552f344cc6d1bf979d3422f6.svg',
            size: '',
            title: 'This job requires a manual action',
            content:
              'This job requires manual intervention to start. Before starting this job, you can add variables below for last-minute configuration changes.',
          },
          favicon:
            '/assets/ci_favicons/favicon_status_manual-829a0804612cef47d9efc1618dba38325483657c847dba0546c3b9f0295bb36c.png',
          action: {
            icon: 'play',
            title: 'Play',
            path: '/h5bp/html5-boilerplate/-/jobs/1015/play',
            method: 'post',
            buttonTitle: 'Run job',
          },
        },
      },
    ],
    scheduledActions: [],
    cluster: null,
  },
  hasStopAction: false,
  rolloutStatus: null,
  environmentPath: '/h5bp/html5-boilerplate/-/environments/41',
  stopPath: '/h5bp/html5-boilerplate/-/environments/41/stop',
  cancelAutoStopPath: '/h5bp/html5-boilerplate/-/environments/41/cancel_auto_stop',
  deletePath: '/api/v4/projects/8/environments/41',
  folderPath: '/h5bp/html5-boilerplate/-/environments/folders/review',
  createdAt: '2021-10-04T19:27:00.527Z',
  updatedAt: '2021-10-04T19:27:00.527Z',
  canStop: true,
  logsPath: '/h5bp/html5-boilerplate/-/logs?environment_name=review%2Fhello',
  logsApiPath: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=review%2Fhello',
  enableAdvancedLogsQuerying: false,
  canDelete: false,
  hasOpenedAlert: false,
  __typename: 'LocalEnvironment',
};

export const resolvedFolder = {
  activeCount: 2,
  environments: [
    {
      id: 42,
      globalId: 'gid://gitlab/Environment/42',
      name: 'review/goodbye',
      state: 'available',
      externalUrl: 'https://example.org',
      environmentType: 'review',
      nameWithoutType: 'goodbye',
      lastDeployment: null,
      hasStopAction: false,
      rolloutStatus: null,
      environmentPath: '/h5bp/html5-boilerplate/-/environments/42',
      stopPath: '/h5bp/html5-boilerplate/-/environments/42/stop',
      cancelAutoStopPath: '/h5bp/html5-boilerplate/-/environments/42/cancel_auto_stop',
      deletePath: '/api/v4/projects/8/environments/42',
      folderPath: '/h5bp/html5-boilerplate/-/environments/folders/review',
      createdAt: '2021-10-04T19:27:20.639Z',
      updatedAt: '2021-10-04T19:27:20.639Z',
      canStop: true,
      logsPath: '/h5bp/html5-boilerplate/-/logs?environment_name=review%2Fgoodbye',
      logsApiPath: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=review%2Fgoodbye',
      enableAdvancedLogsQuerying: false,
      canDelete: false,
      hasOpenedAlert: false,
      __typename: 'LocalEnvironment',
    },
    {
      id: 41,
      globalId: 'gid://gitlab/Environment/41',
      name: 'review/hello',
      state: 'available',
      externalUrl: 'https://example.org',
      environmentType: 'review',
      nameWithoutType: 'hello',
      lastDeployment: null,
      hasStopAction: false,
      rolloutStatus: null,
      environmentPath: '/h5bp/html5-boilerplate/-/environments/41',
      stopPath: '/h5bp/html5-boilerplate/-/environments/41/stop',
      cancelAutoStopPath: '/h5bp/html5-boilerplate/-/environments/41/cancel_auto_stop',
      deletePath: '/api/v4/projects/8/environments/41',
      folderPath: '/h5bp/html5-boilerplate/-/environments/folders/review',
      createdAt: '2021-10-04T19:27:00.527Z',
      updatedAt: '2021-10-04T19:27:00.527Z',
      canStop: true,
      logsPath: '/h5bp/html5-boilerplate/-/logs?environment_name=review%2Fhello',
      logsApiPath: '/h5bp/html5-boilerplate/-/logs/k8s.json?environment_name=review%2Fhello',
      enableAdvancedLogsQuerying: false,
      canDelete: false,
      hasOpenedAlert: false,
      __typename: 'LocalEnvironment',
    },
  ],
  stoppedCount: 0,
  __typename: 'LocalEnvironmentFolder',
};

export const resolvedDeploymentDetails = {
  data: {
    project: {
      id: 'gid://gitlab/Project/20',
      deployment: {
        id: 'gid://gitlab/Deployment/99',
        iid: '55',
        tags: [
          {
            name: 'testTag1',
            path: 'tags/testTag1',
          },
          {
            name: 'testTag2',
            path: 'tags/testTag2',
          },
          {
            name: 'testTag3',
            path: 'tags/testTag3',
          },
          {
            name: 'testTag4',
            path: 'tags/testTag4',
          },
          {
            name: 'testTag5',
            path: 'tags/testTag5',
          },
          {
            name: 'testTag6',
            path: 'tags/testTag6',
          },
        ],
      },
    },
  },
};

export const agent = {
  id: 'gid://gitlab/ClusterAgent/1',
  name: 'agent-name',
  webPath: 'path/to/agent-page',
  tokens: { nodes: [] },
};

export const kubernetesNamespace = 'agent-namespace';

export const k8sNamespacesMock = [
  { metadata: { name: 'default' } },
  { metadata: { name: 'agent' } },
];

const fluxResourceStatusMock = [{ status: 'True', type: 'Ready', message: '', reason: '' }];
const fluxResourceMetadataMock = {
  name: 'custom-resource',
  namespace: 'custom-namespace',
  annotations: {},
  labels: {},
};
export const fluxKustomizationMock = {
  kind: 'Kustomization',
  metadata: fluxResourceMetadataMock,
  status: { conditions: fluxResourceStatusMock, inventory: { entries: [{ id: 'test_resource' }] } },
};
export const fluxHelmReleaseMock = {
  kind: 'HelmRelease',
  metadata: fluxResourceMetadataMock,
  status: { conditions: fluxResourceStatusMock },
};
export const fluxKustomizationMapped = {
  kind: 'Kustomization',
  metadata: fluxResourceMetadataMock,
  spec: {},
  status: fluxKustomizationMock.status,
  conditions: fluxResourceStatusMock,
  inventory: [{ id: 'test_resource' }],
  __typename: 'LocalWorkloadItem',
};
export const fluxHelmReleaseMapped = {
  kind: 'HelmRelease',
  metadata: fluxResourceMetadataMock,
  spec: {},
  status: { conditions: fluxResourceStatusMock },
  conditions: fluxResourceStatusMock,
  __typename: 'LocalWorkloadItem',
};

export const fluxResourcePathMock = 'kustomize.toolkit.fluxcd.io/v1/path/to/flux/resource';

export const resolvedEnvironmentToDelete = {
  __typename: 'LocalEnvironment',
  id: 41,
  name: 'review/hello',
  deletePath: '/api/v4/projects/8/environments/41',
};

export const resolvedEnvironmentToRollback = {
  __typename: 'LocalEnvironment',
  id: 41,
  name: 'review/hello',
  lastDeployment: {
    id: 78,
    iid: 24,
    sha: 'f3ba6dd84f8f891373e9b869135622b954852db1',
    ref: { name: 'main', refPath: '/h5bp/html5-boilerplate/-/tree/main' },
    status: 'success',
    createdAt: '2022-01-07T15:47:27.415Z',
    deployedAt: '2022-01-07T15:47:32.450Z',
    tierInYaml: 'staging',
    tag: false,
    isLast: true,
    user: {
      id: 1,
      username: 'root',
      name: 'Administrator',
      state: 'active',
      avatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      webUrl: 'http://gck.test:3000/root',
      showStatus: false,
      path: '/root',
    },
    deployable: {
      id: 1014,
      name: 'deploy-prod',
      started: '2022-01-07T15:47:31.037Z',
      complete: true,
      archived: false,
      buildPath: '/h5bp/html5-boilerplate/-/jobs/1014',
      retryPath: '/h5bp/html5-boilerplate/-/jobs/1014/retry',
      playable: false,
      scheduled: false,
      createdAt: '2022-01-07T15:47:27.404Z',
      updatedAt: '2022-01-07T15:47:32.341Z',
      status: {
        action: {
          buttonTitle: 'Retry this job',
          icon: 'retry',
          method: 'post',
          path: '/h5bp/html5-boilerplate/-/jobs/1014/retry',
          title: 'Retry',
        },
        detailsPath: '/h5bp/html5-boilerplate/-/jobs/1014',
        favicon:
          '/assets/ci_favicons/favicon_status_success-8451333011eee8ce9f2ab25dc487fe24a8758c694827a582f17f42b0a90446a2.png',
        group: 'success',
        hasDetails: true,
        icon: 'status_success',
        illustration: {
          image:
            '/assets/illustrations/empty-state/empty-job-skipped-md-29a8a37d8a61d1b6f68cf3484f9024e53cd6eb95e28eae3554f8011a1146bf27.svg',
          size: '',
          title: 'This job does not have a trace.',
        },
        label: 'passed',
        text: 'passed',
        tooltip: 'passed',
      },
    },
    commit: {
      id: 'f3ba6dd84f8f891373e9b869135622b954852db1',
      shortId: 'f3ba6dd8',
      createdAt: '2022-01-07T15:47:26.000+00:00',
      parentIds: ['3213b6ac17afab99be37d5d38f38c6c8407387cc'],
      title: 'Update .gitlab-ci.yml file',
      message: 'Update .gitlab-ci.yml file',
      authorName: 'Administrator',
      authorEmail: 'admin@example.com',
      authoredDate: '2022-01-07T15:47:26.000+00:00',
      committerName: 'Administrator',
      committerEmail: 'admin@example.com',
      committedDate: '2022-01-07T15:47:26.000+00:00',
      trailers: {},
      webUrl:
        'http://gck.test:3000/h5bp/html5-boilerplate/-/commit/f3ba6dd84f8f891373e9b869135622b954852db1',
      author: {
        avatarUrl:
          'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
        id: 1,
        name: 'Administrator',
        path: '/root',
        showStatus: false,
        state: 'active',
        username: 'root',
        webUrl: 'http://gck.test:3000/root',
      },
      authorGravatarUrl:
        'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      commitUrl:
        'http://gck.test:3000/h5bp/html5-boilerplate/-/commit/f3ba6dd84f8f891373e9b869135622b954852db1',
      commitPath: '/h5bp/html5-boilerplate/-/commit/f3ba6dd84f8f891373e9b869135622b954852db1',
    },
    manualActions: [
      {
        id: 1015,
        name: 'deploy-staging',
        started: null,
        complete: false,
        archived: false,
        buildPath: '/h5bp/html5-boilerplate/-/jobs/1015',
        playPath: '/h5bp/html5-boilerplate/-/jobs/1015/play',
        playable: true,
        scheduled: false,
        createdAt: '2022-01-07T15:47:27.422Z',
        updatedAt: '2022-01-07T15:47:28.557Z',
        status: {
          icon: 'status_manual',
          text: 'manual',
          label: 'manual play action',
          group: 'manual',
          tooltip: 'manual action',
          hasDetails: true,
          detailsPath: '/h5bp/html5-boilerplate/-/jobs/1015',
          illustration: {
            image:
              '/assets/illustrations/empty-state/empty-job-manual-md-c55aee2c5f9ebe9f72751480af8bb307be1a6f35552f344cc6d1bf979d3422f6.svg',
            size: '',
            title: 'This job requires a manual action',
            content:
              'This job requires manual intervention to start. Before starting this job, you can add variables below for last-minute configuration changes.',
          },
          favicon:
            '/assets/ci_favicons/favicon_status_manual-829a0804612cef47d9efc1618dba38325483657c847dba0546c3b9f0295bb36c.png',
          action: {
            icon: 'play',
            title: 'Play',
            path: '/h5bp/html5-boilerplate/-/jobs/1015/play',
            method: 'post',
            buttonTitle: 'Run job',
          },
        },
      },
    ],
    scheduledActions: [],
    cluster: null,
  },
  retryUrl: '/h5bp/html5-boilerplate/-/jobs/1014/retry',
};
