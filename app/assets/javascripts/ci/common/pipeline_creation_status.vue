<script>
import getPipelineCreationStatus from '~/ci/common/graphql/queries/get_pipeline_creation_status.query.graphql';
import pipelineCreationStatusSubscription from '~/ci/common/graphql/subscriptions/pipeline_creation_status.subscription.graphql';
import { TYPENAME_MERGE_REQUEST } from '~/graphql_shared/constants';
import { convertToGraphQLId } from '~/graphql_shared/utils';

/**
 * Renderless component that wraps a GraphQL query for pipeline creation
 * and updates the status for apps which need this logic.
 *
 * You can use the slot to define a presentation for a run pipeline button.

 * Usage:
 *
 * ```vue
 * <pipeline-creation-status
 *   #default="{ isCreating }"
 *   :full-path="fullPath"
 *   :id="id"
 *   @updated="onPipelineCreationStatusUpdated"
 * >
 *   <button :loading="isCreating" @click="anyMethodInParentComponent">{{ Run pipeline }}</button>
 * </pipeline-creation-status>
 * ```
 *
 */

export default {
  name: 'PipelineCreationStatus',
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    id: {
      type: String,
      required: true,
    },
  },
  emits: ['updated'],
  data() {
    return {
      pipelineCreationStatus: '',
    };
  },
  apollo: {
    pipelineCreationStatus: {
      query: getPipelineCreationStatus,
      variables() {
        return {
          fullPath: this.fullPath,
          id: this.id,
        };
      },
      update(data) {
        const status = data?.project?.ciPipelineCreation?.status || 'SUCCEEDED';
        this.$emit('updated', status);
        return status;
      },
      subscribeToMore: {
        document() {
          return pipelineCreationStatusSubscription;
        },
        variables() {
          return {
            issuableId: convertToGraphQLId(TYPENAME_MERGE_REQUEST, this.id),
          };
        },
        updateQuery(
          _,
          {
            subscriptionData: {
              data: { pipelineCreationStatusUpdated },
            },
          },
        ) {
          if (pipelineCreationStatusUpdated) {
            this.pipelineCreationStatus = pipelineCreationStatusUpdated;
          }
        },
      },
    },
  },
  computed: {
    isCreating() {
      return this.pipelineCreationStatus === 'CREATING';
    },
  },
  render() {
    return this.$scopedSlots.default({
      isCreating: this.isCreating,
    });
  },
};
</script>
