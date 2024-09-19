# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqClientMiddleware
        include Gitlab::Utils::StrongMemoize
        include WalTrackingSender

        def call(worker_class, job, _queue, _redis_pool)
          # Mailers can't be constantized
          worker_class = worker_class.to_s.safe_constantize
          # ActiveJobs have wrapped class stored in 'wrapped' key
          resolved_class = job['wrapped'].to_s.safe_constantize || worker_class

          if load_balancing_enabled?(resolved_class)
            job['worker_data_consistency'] = resolved_class.get_data_consistency
            set_data_consistency_locations!(job) unless job['wal_locations']
          else
            job['worker_data_consistency'] = ::WorkerAttributes::DEFAULT_DATA_CONSISTENCY
          end

          yield
        end

        private

        def load_balancing_enabled?(worker_class)
          worker_class &&
            worker_class.include?(::WorkerAttributes) &&
            worker_class.utilizes_load_balancing_capabilities? &&
            worker_class.get_data_consistency_feature_flag_enabled?
        end

        def set_data_consistency_locations!(job)
          wal_loc = wal_locations_by_db_name
          job['wal_locations'] = wal_loc
          job['wal_location_sources'] = wal_loc.to_h { |k, _| [k, wal_location_source(k)] }
        end

        def wal_location_source(lb_name)
          if ::Gitlab::Database::LoadBalancing.primary?(lb_name) || uses_primary?(lb_name)
            ::Gitlab::Database::LoadBalancing::ROLE_PRIMARY
          else
            ::Gitlab::Database::LoadBalancing::ROLE_REPLICA
          end
        end

        def uses_primary?(lb_name)
          ::Gitlab::Database::LoadBalancing::Session.current.use_primary?(lb_name)
        end
      end
    end
  end
end
