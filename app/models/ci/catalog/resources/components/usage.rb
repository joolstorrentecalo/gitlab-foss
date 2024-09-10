# frozen_string_literal: true

module Ci
  module Catalog
    module Resources
      module Components
        # This model is used to track when a project includes a catalog component in
        # a pipeline with the keyword `include:component`. Usage data is recorded
        # during pipeline creation in Gitlab::Ci::Pipeline::Chain::ComponentUsage.
        # The column `used_by_project_id` does not have an FK constraint because
        # we want to preserve historical usage data.
        class Usage < ::ApplicationRecord
          include PartitionedTable
          include EachBatch

          self.table_name = 'p_catalog_resource_component_usages'
          self.primary_key = :id

          # TODO: Retention period to be shortened in https://gitlab.com/gitlab-org/gitlab/-/issues/443681
          partitioned_by :used_date, strategy: :monthly, retain_for: 12.months

          belongs_to :component, class_name: 'Ci::Catalog::Resources::Component', inverse_of: :usages
          belongs_to :catalog_resource, class_name: 'Ci::Catalog::Resource', inverse_of: :component_usages
          belongs_to :project, inverse_of: :ci_component_usages

          validates :component, :catalog_resource, :project, :used_by_project_id, presence: true
          validates :used_date, uniqueness: { scope: [:component_id, :used_by_project_id] }

          before_validation :set_used_date, unless: :used_date?

          def self.used_by_project_ids(projects, days: 30)
            start_date = Date.today - days.days
            project_ids = where('used_date >= ?', start_date)
                          .select(:used_by_project_id)
                          .distinct
            projects.select(:id).where(id: project_ids)
          end

          def self.fetch_ci_components_used(project, days: 30)
            start_date = Date.today - days.days
            joins(component: :version)
              .where(used_by_project_id: project.id)
              .where('used_date >= ?', start_date)
              .group(:component_id)
              .select('MAX(used_date) as latest_used_date, component_id')
              .map do |usage|
                component = usage.component
                {
                  name: component.name,
                  version: component.version.name,
                  used_date: usage.latest_used_date
                }
              end
          end

          private

          def set_used_date
            self.used_date = Date.today
          end
        end
      end
    end
  end
end
