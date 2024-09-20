# frozen_string_literal: true

require 'fileutils'
require 'yaml'

ApplicationSettingAttr = Struct.new(:attr, :type, :encrypted, :not_null, :default, :gitlab_com_different_than_default,
  :description, :jihu, :clusterwide, keyword_init: true)
SPECIAL_CASES = {
  'default_group_visibility' => 'integer',
  'default_project_visibility' => 'integer',
  'default_snippet_visibility' => 'integer',
  'email_confirmation_setting' => 'integer',
  'performance_bar_allowed_group_id' => 'integer',
  'sidekiq_job_limiter_mode' => 'integer',
  'whats_new_variant' => 'integer'
}.freeze
# Computed from Teleport Rails console with:
# ```shell
# $ as = ApplicationSetting.first
# $ as_defaults = ApplicationSetting.defaults
# $ new_as = ApplicationSetting.new
# $ as.attributes.to_h.each { |k, v| puts "#{k} different than defaults" \
# if (as_defaults.key?(k) && as_defaults[k] != v) || (new_as[k] != v) }; nil
# ```
#
# rubocop:disable Naming/InclusiveLanguage -- This is the actual column name
GITLAB_COM_DIFFERENT_THAN_DEFAULT = %w[
  abuse_notification_email
  after_sign_out_path
  after_sign_up_text
  arkose_labs_namespace
  asset_proxy_enabled
  asset_proxy_url
  asset_proxy_whitelist
  authorized_keys_enabled
  auto_devops_domain
  auto_devops_enabled
  automatic_purchased_storage_allocation
  check_namespace_plan
  clickhouse
  cluster_agents
  code_creation
  commit_email_hostname
  container_expiration_policies_enable_historic_entries
  container_registry_data_repair_detail_worker_max_concurrency
  container_registry_db_enabled
  container_registry_expiration_policies_worker_capacity
  container_registry_features
  container_registry_token_expire_delay
  container_registry_vendor
  container_registry_version
  created_at
  cube_api_base_url
  custom_http_clone_url_root
  dashboard_limit
  dashboard_limit_enabled
  database_grafana_api_url
  database_grafana_tag
  database_max_running_batched_background_migrations
  deactivation_email_additional_text
  default_artifacts_expire_in
  default_branch_name
  default_ci_config_path
  default_group_visibility
  default_projects_limit
  diff_max_files
  diff_max_lines
  domain_denylist
  domain_denylist_enabled
  downstream_pipeline_trigger_limit_per_project_user_sha
  duo_workflow
  duo_workflow_oauth_application_id
  eks_access_key_id
  eks_account_id
  eks_integration_enabled
  elasticsearch_aws_access_key
  elasticsearch_client_request_timeout
  elasticsearch_indexed_field_length_limit
  elasticsearch_indexing
  elasticsearch_limit_indexing
  elasticsearch_max_code_indexing_concurrency
  elasticsearch_requeue_workers
  elasticsearch_search
  elasticsearch_url
  elasticsearch_username
  elasticsearch_worker_number_of_shards
  email_additional_text
  email_confirmation_setting
  email_restrictions
  email_restrictions_enabled
  enabled_git_access_protocol
  encrypted_akismet_api_key
  encrypted_arkose_labs_client_secret
  encrypted_arkose_labs_client_xid
  encrypted_arkose_labs_data_exchange_key
  encrypted_arkose_labs_private_api_key
  encrypted_arkose_labs_public_api_key
  encrypted_asset_proxy_secret_key
  encrypted_ci_jwt_signing_key
  encrypted_cube_api_key
  encrypted_customers_dot_jwt_signing_key
  encrypted_database_grafana_api_key
  encrypted_eks_secret_access_key
  encrypted_elasticsearch_aws_secret_access_key
  encrypted_elasticsearch_password
  encrypted_external_pipeline_validation_service_token
  encrypted_lets_encrypt_private_key
  encrypted_mailgun_signing_key
  encrypted_product_analytics_configurator_connection_string
  encrypted_recaptcha_private_key
  encrypted_recaptcha_site_key
  encrypted_secret_detection_token_revocation_token
  encrypted_slack_app_secret
  encrypted_slack_app_signing_secret
  encrypted_slack_app_verification_token
  encrypted_spam_check_api_key
  encrypted_telesign_api_key
  encrypted_telesign_customer_xid
  enforce_terms
  error_tracking_access_token_encrypted
  error_tracking_api_url
  error_tracking_enabled
  external_authorization_service_default_label
  external_authorization_service_url
  external_pipeline_validation_service_timeout
  external_pipeline_validation_service_url
  geo_status_timeout
  gitpod_enabled
  globally_allowed_ips
  gravatar_enabled
  health_check_access_token
  help_page_documentation_base_url
  help_page_support_url
  help_page_text
  home_page_url
  import_sources
  importers
  invisible_captcha_enabled
  issues_create_limit
  jira_connect_application_key
  jira_connect_proxy_url
  jira_connect_public_key_storage_enabled
  lets_encrypt_notification_email
  lets_encrypt_terms_of_service_accepted
  local_markdown_version
  mailgun_events_enabled
  maven_package_requests_forwarding
  max_artifacts_size
  max_export_size
  max_import_size
  max_pages_custom_domains_per_project
  max_pages_size
  metrics_enabled
  metrics_method_call_threshold
  metrics_packet_size
  metrics_port
  mirror_capacity_threshold
  mirror_max_capacity
  mirror_max_delay
  namespace_storage_forks_cost_factor
  notes_create_limit
  notes_create_limit_allowlist
  outbound_local_requests_whitelist
  package_registry
  pages
  password_authentication_enabled_for_web
  performance_bar_allowed_group_id
  pipeline_limit_per_project_user_sha
  plantuml_enabled
  plantuml_url
  pre_receive_secret_detection_enabled
  product_analytics_data_collector_host
  product_analytics_enabled
  productivity_analytics_start_date
  prometheus_alert_db_indicators_settings
  push_rule_id
  rate_limiting_response_text
  rate_limits
  rate_limits_unauthenticated_git_http
  recaptcha_enabled
  receive_max_input_size
  repository_size_limit
  repository_storages
  repository_storages_weighted
  require_admin_approval_after_user_signup
  require_admin_two_factor_authentication
  restricted_visibility_levels
  runners_registration_token
  runners_registration_token_encrypted
  search_rate_limit
  search_rate_limit_allowlist
  secret_detection_revocation_token_types_url
  secret_detection_token_revocation_enabled
  secret_detection_token_revocation_url
  security_policies
  security_policy_global_group_approvers_enabled
  security_policy_scheduled_scans_max_concurrency
  security_txt_content
  sentry_clientside_dsn
  sentry_clientside_traces_sample_rate
  sentry_dsn
  sentry_enabled
  sentry_environment
  service_ping_settings
  shared_runners_minutes
  shared_runners_text
  sidekiq_job_limiter_limit_bytes
  signup_enabled
  silent_admin_exports_enabled
  slack_app_enabled
  slack_app_id
  snowplow_app_id
  snowplow_collector_hostname
  snowplow_cookie_domain
  snowplow_enabled
  sourcegraph_enabled
  sourcegraph_url
  spam_check_endpoint_enabled
  spam_check_endpoint_url
  static_objects_external_storage_auth_token_encrypted
  static_objects_external_storage_url
  throttle_authenticated_api_period_in_seconds
  throttle_authenticated_api_requests_per_period
  throttle_authenticated_deprecated_api_period_in_seconds
  throttle_authenticated_web_period_in_seconds
  throttle_authenticated_web_requests_per_period
  throttle_incident_management_notification_enabled
  throttle_protected_paths_enabled
  throttle_unauthenticated_api_enabled
  throttle_unauthenticated_api_period_in_seconds
  throttle_unauthenticated_api_requests_per_period
  throttle_unauthenticated_deprecated_api_requests_per_period
  throttle_unauthenticated_enabled
  throttle_unauthenticated_git_http_enabled
  throttle_unauthenticated_git_http_period_in_seconds
  throttle_unauthenticated_git_http_requests_per_period
  throttle_unauthenticated_period_in_seconds
  throttle_unauthenticated_requests_per_period
  time_tracking_limit_to_hours
  unconfirmed_users_delete_after_days
  unique_ips_limit_per_user
  unique_ips_limit_time_window
  updated_at
  usage_stats_set_by_user_id
  use_clickhouse_for_analytics
  user_default_internal_regex
  users_get_by_id_limit_allowlist
  uuid
  vertex_ai_project
  web_ide_oauth_application_id
  zoekt_cpu_to_tasks_ratio
  zoekt_indexing_enabled
  zoekt_search_enabled
  zoekt_settings
].freeze
# rubocop:enable Naming/InclusiveLanguage

structure_sql = File.read(File.expand_path('../../db/structure.sql', __dir__))
match = structure_sql.match(/CREATE TABLE application_settings \((?<columns>.+?)\);/m)
jihu_columns = structure_sql.scan(
  /COMMENT ON COLUMN application_settings.(?<column>\w+) IS 'JiHu-specific column';/
).flatten
structure_columns = match[:columns].lines(chomp: true).map(&:strip).reject do |line|
  line.empty? || line.start_with?('CONSTRAINT')
end.sort

settings_md = File.read(File.expand_path('../../doc/api/settings.md', __dir__))
match = settings_md.match(
  Regexp.new("## List of settings that can be accessed via API calls(?:.*?)(?:--\|\n)+?(?<rows>.+)" \
    "### Configure inactive project deletion", Regexp::MULTILINE)
)
doc_rows = match[:rows].lines(chomp: true).map(&:strip).filter_map do |line|
  line.delete_prefix("| ") if line.start_with?('| `')
end.sort

application_setting_attrs = []

structure_columns.each do |line|
  # throttle_authenticated_packages_api_requests_per_period integer DEFAULT 1000 NOT NULL
  # valid_runner_registrars character varying[] DEFAULT '{project,group}'::character varying[]
  attr, type = line.chomp(',').split(' ').map(&:strip)
  next if attr.end_with?('_html') # ignore Markdown-caching extra columns
  next if attr.match?(/^encrypted_\w+_iv/) # ignore encryption-related extra columns

  encrypted = attr.start_with?('encrypted_')
  attr.delete_prefix!('encrypted_')
  type =
    case type
    when 'character', 'text', 'text[]', 'bytea'
      'string'
    when 'smallint', 'bigint'
      'integer'
    when 'double', 'numeric'
      'float'
    when 'jsonb'
      'hash'
    when 'smallint[]'
      'integer[]'
    else
      type
    end
  not_null = line.include?('NOT NULL') ? true : false

  match = line.match(/DEFAULT (?<default>[^\s,]+)/)
  default = match ? match[:default] : nil

  application_setting_attrs << ApplicationSettingAttr.new(attr: attr, type: type, encrypted: encrypted,
    not_null: not_null, default: default, jihu: jihu_columns.include?(attr))
end

doc_rows.each do |line|
  attr, type, _required, description = line.split('|').map(&:strip)
  attr.delete!('`')
  type =
    case type
    when 'array of strings', 'string or array of strings'
      'string'
    when 'array of integers'
      'integer[]'
    when 'hash of strings to integers'
      'hash'
    when 'object'
      'hash'
    else
      SPECIAL_CASES.fetch(attr, type)
    end

  existing_application_setting = application_setting_attrs.find { |as| as.attr == attr }
  if existing_application_setting
    unless existing_application_setting.type == type
      raise "`#{attr}`: Not consistent type `#{type}` with existing `#{existing_application_setting.type}`!"
    end

    existing_application_setting.description = description
  else
    puts "API setting #{attr} doesn't actually exist as a DB column in `application_settings`!"
  end
end

all_as = application_setting_attrs.map do |as|
  doc_filename = File.expand_path("../../db/docs/application_settings/#{as.attr}.yml", __dir__)

  # Ensure folder exists
  FileUtils.mkdir_p(File.dirname(doc_filename))

  as_doc = nil
  # If the YAML file doesn't exist, create it
  if File.exist?(doc_filename)
    as_doc = YAML.safe_load_file(doc_filename)
    as = ApplicationSettingAttr.new(as_doc.merge(as.to_h.reject { |_k, v| v.nil? }))
    as.gitlab_com_different_than_default ||= GITLAB_COM_DIFFERENT_THAN_DEFAULT.include?(as.attr) ||
      GITLAB_COM_DIFFERENT_THAN_DEFAULT.include?("encrypted_#{as.attr}")
  end

  File.write(doc_filename, Hash[as.to_h.sort].transform_keys(&:to_s).to_yaml) if as_doc.nil? || as_doc != as
  as
end

doc_page = [
  "---",
  "stage: Data Stores",
  "group: Tenant Scale",
  "info: Analysis of Application Settings for Cells 1.0.",
  "---",
  "## Some statistics\n"
]

doc_page << "- Number of attributes: #{all_as.count}"
as_encrypted = all_as.count(&:encrypted)
doc_page << "- Number of encrypted attributes: #{as_encrypted} (#{(as_encrypted.to_f / all_as.count).round(2) * 100}%)"
as_documented = all_as.count(&:description)
doc_page << "- Number of attributes documented: #{as_documented} " \
  "(#{(as_documented.to_f / all_as.count).round(2) * 100}%)"
as_on_gitlab_com_different_than_default = all_as.count(&:gitlab_com_different_than_default)
doc_page << "- Number of attributes on GitLab.com different from the defaults: " \
  "#{as_on_gitlab_com_different_than_default} " \
  "(#{(as_on_gitlab_com_different_than_default.to_f / all_as.count).round(2) * 100}%)"
as_with_clusterwide_set = all_as.count { |as| !as.clusterwide.nil? }
doc_page << "- Number of attributes with `clusterwide` set: #{as_with_clusterwide_set} " \
  "(#{(as_with_clusterwide_set.to_f / all_as.count).round(2) * 100}%)\n"

doc_page << "| Attribute name | Type (casted) | Encrypted | Not Null? | Default (DB type) | GitLab.com != default " \
  "| Cluster-wide? | Documented? |"
doc_page << "| -------------- | ------------- | --------- | --------- | ----------------- | --------------------- " \
  "| ------------- | ----------- |"

all_as.each do |as|
  jihu = as.jihu ? ' [JIHU]' : ''
  doc_page << "| `#{as.attr}`#{jihu} | `#{as.type}` | `#{as.encrypted}` | `#{as.not_null}` " \
    "| `#{as.default || (as.not_null ? '???' : 'null')}` | `#{as.gitlab_com_different_than_default}` " \
    "| `#{as.clusterwide.nil? ? '???' : as.clusterwide}`| `#{!!as.description}` |"
end

doc_page << '' # trailing line

File.write(File.expand_path("../../doc/development/cells/application_settings_analysis.md", __dir__),
  doc_page.join("\n"))
