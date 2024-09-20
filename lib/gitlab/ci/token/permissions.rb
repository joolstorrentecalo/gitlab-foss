# frozen_string_literal: true

module Gitlab
  module Ci
    module Token
      module Permissions
        # all CI job tokens need these permissions
        FIXED = [
          :read_project,
          :read_package,
          :read_container_image,
          :build_download_code,
          :build_push_code,
          :build_read_container_image,
          :build_create_container_image,
          :build_destroy_container_image
        ].freeze

        # permissions that can be assigned to a job token to access group endpoints
        ALLOWED_GROUP_ABILITIES = [
          :read_group,
          :create_package,
          :destroy_package
        ].freeze

        # permissions that can be assigned to a job token to access group endpoints
        ALLOWED_PROJECT_ABILITIES = [
          :read_pipeline,
          :read_terraform_state,
          :read_release,
          :read_build,
          :read_job_artifacts,
          :read_secure_files,
          :read_deployment,
          :read_environment,
          :create_package,
          :create_on_demand_dast_scan,
          :create_release,
          :create_deployment,
          :create_environment,
          :update_release,
          :update_pipeline,
          :update_deployment,
          :update_environment,
          :destroy_package,
          :destroy_release,
          :destroy_deployment,
          :destroy_environment,
          :stop_environment,
          :destroy_container_image,
          :admin_secure_files,
          :admin_terraform_state,
          :admin_container_image
        ].freeze
      end
    end
  end
end
