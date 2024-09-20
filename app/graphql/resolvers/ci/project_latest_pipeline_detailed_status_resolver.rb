# frozen_string_literal: true

module Resolvers
  module Ci
    class ProjectLatestPipelineDetailedStatusResolver < BaseResolver
      type Types::Ci::DetailedStatusType, null: true

      alias_method :project, :object

      def resolve
        pipeline_status = Gitlab::Cache::Ci::ProjectPipelineStatus.new(project)

        # Get the HEAD SHA avoiding gitaly calls
        sha = if pipeline_status.has_cache?
                pipeline_status.load_from_cache
                pipeline_status&.sha
              else
                project.commit&.sha
              end

        # Batch load the latest Pipeline per commit and project, since the sha is unique per project only
        latest_pipelines = BatchLoader::GraphQL.for([project.id, sha]).batch do |tuples, loader|
          shas = tuples.pluck(1) # rubocop:disable CodeReuse/ActiveRecord -- not an active record relation

          # This query also needs the project_id, the sha is not unique per repo. Relevant specs are needed.
          # Preloading is needed for authorization
          preload_pipelines = ::Ci::Pipeline.latest_pipeline_per_commit(shas, nil,
            [{ project: [:project_feature, :group] }])
          tuples.each do |tuple|
            pipeline = preload_pipelines[tuple[1]]
            pipeline&.number_of_warnings
            loader.call(tuple, pipeline)
          end
        end

        ::Gitlab::Graphql::Lazy.with_value(latest_pipelines) do |pipeline|
          next nil unless pipeline.present?
          next nil unless Ability.allowed?(current_user, :read_pipeline, pipeline)

          pipeline.detailed_status(current_user)
        end
      end
    end
  end
end
