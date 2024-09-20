# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class BackfillPackagesNugetSymbolsProjectId < BatchedMigrationJob
      operation_name :update_all # This is used as the key on collecting metrics
      scope_to ->(relation) { relation.where(project_id: nil) }
      feature_category :package_registry

      def perform
        each_sub_batch do |sub_batch|
          joined = sub_batch
            .joins('INNER JOIN packages_packages ON packages_nuget_symbols.package_id = packages_packages.id')
            .select('packages_nuget_symbols.id, packages_packages.project_id')

          ApplicationRecord.connection.execute <<~SQL
            WITH joined_cte(packages_nuget_symbol_id, project_id) AS MATERIALIZED (
              #{joined.to_sql}
            )
            UPDATE packages_nuget_symbols
            SET project_id = joined_cte.project_id
            FROM joined_cte
            WHERE id = joined_cte.packages_nuget_symbol_id
          SQL
        end
      end
    end
  end
end
