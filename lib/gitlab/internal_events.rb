# frozen_string_literal: true

module Gitlab
  module InternalEvents
    UnknownEventError = Class.new(StandardError)
    InvalidPropertyError = Class.new(StandardError)
    InvalidPropertyTypeError = Class.new(StandardError)

    SNOWPLOW_EMITTER_BUFFER_SIZE = 100
    DEFAULT_BUFFER_SIZE = 1
    ALLOWED_ADDITIONAL_PROPERTIES = {
      label: [String],
      property: [String],
      value: [Integer, Float]
    }.freeze
    DEFAULT_ADDITIONAL_PROPERTIES = {}.freeze

    class << self
      include Gitlab::Tracking::Helpers
      include Gitlab::Utils::StrongMemoize
      include Gitlab::UsageDataCounters::RedisCounter

      def track_event(
        event_name, category: nil, send_snowplow_event: true,
        additional_properties: DEFAULT_ADDITIONAL_PROPERTIES, **kwargs)
        raise UnknownEventError, "Unknown event: #{event_name}" unless EventDefinitions.known_event?(event_name)

        validate_properties!(additional_properties, kwargs)

        project = kwargs[:project]
        kwargs[:namespace] ||= project.namespace if project

        update_redis_values(event_name, additional_properties)
        update_unique_counters(event_name, kwargs)

        trigger_snowplow_event(event_name, category, additional_properties, kwargs) if send_snowplow_event
        send_application_instrumentation_event(event_name, additional_properties, kwargs) if send_snowplow_event

        if Feature.enabled?(:early_access_program, kwargs[:user], type: :wip)
          create_early_access_program_event(event_name, category, additional_properties[:label], kwargs[:user])
        end
      rescue StandardError => e
        extra = {}
        kwargs.each_key do |k|
          extra[k] = kwargs[k].is_a?(::ApplicationRecord) ? kwargs[k].try(:id) : kwargs[k]
        end
        Gitlab::ErrorTracking.track_and_raise_for_dev_exception(
          e,
          event_name: event_name,
          additional_properties: additional_properties,
          kwargs: extra
        )
        nil
      end

      def convert_event_selection_rule_to_path_part(event_selection_rule)
        path = event_selection_rule[:name]

        if event_selection_rule[:filter].present?
          filter = event_selection_rule[:filter]
          sorted_filter_keys = filter.keys.sort
          serialized_filter = sorted_filter_keys.map { |key| "#{key}:#{filter[key]}" }.join(',')
          path = "#{path}-filter:[#{serialized_filter}]"
        end

        path
      end

      private

      def validate_properties!(additional_properties, kwargs)
        validate_property!(kwargs, :user, User)
        validate_property!(kwargs, :namespace, Namespaces::UserNamespace, Group)
        validate_property!(kwargs, :project, Project)
        validate_additional_properties!(additional_properties)
      end

      def validate_property!(hash, key, *class_names)
        return unless hash.has_key?(key)
        return if hash[key].nil?
        return if class_names.include?(hash[key].class)

        raise InvalidPropertyTypeError, "#{key} should be an instance of #{class_names.join(', ')}"
      end

      def validate_additional_properties!(additional_properties)
        return if additional_properties.empty?

        disallowed_properties = additional_properties.keys - ALLOWED_ADDITIONAL_PROPERTIES.keys
        unless disallowed_properties.empty?
          info = "Additional properties should include only #{ALLOWED_ADDITIONAL_PROPERTIES.keys}. " \
                 "Disallowed properties found: #{disallowed_properties}"
          raise InvalidPropertyError, info
        end

        additional_properties.each do |key, _value|
          allowed_classes = ALLOWED_ADDITIONAL_PROPERTIES[key]
          validate_property!(additional_properties, key, *allowed_classes)
        end
      end

      def update_redis_values(event_name, additional_properties)
        event_definition = Gitlab::Tracking::EventDefinition.find(event_name)

        return unless event_definition

        event_definition.event_selection_rules.each do |event_selection_rule|
          matches_filter = event_selection_rule[:filter].all? do |property_name, value|
            additional_properties[property_name] == value
          end

          next unless matches_filter

          event_specific_part_of_path = convert_event_selection_rule_to_path_part(event_selection_rule)

          if event_selection_rule[:time_framed?]
            redis_key = Gitlab::Usage::Metrics::Instrumentations::TotalCountMetric.redis_key(
              event_specific_part_of_path,
              Date.today
            )
            increment(redis_key, expiry: 6.weeks)
          else
            increment(Gitlab::Usage::Metrics::Instrumentations::TotalCountMetric.redis_key(event_specific_part_of_path))
          end
        end
      end

      def update_unique_counters(event_name, kwargs)
        unique_properties = EventDefinitions.unique_properties(event_name)
        return if unique_properties.empty?

        unique_properties.each do |property_name|
          unless kwargs[property_name]
            message = "#{event_name} should be triggered with a named parameter '#{property_name}'."
            Gitlab::AppJsonLogger.warn(message: message)
            next
          end

          unique_value = kwargs[property_name].id

          UsageDataCounters::HLLRedisCounter.track_event(event_name, values: unique_value, property_name: property_name)
        end
      end

      def trigger_snowplow_event(event_name, category, additional_properties, kwargs)
        user = kwargs[:user]
        project = kwargs[:project]
        namespace = kwargs[:namespace]
        feature_enabled_by_namespace_ids = kwargs[:feature_enabled_by_namespace_ids]

        standard_context = Tracking::StandardContext.new(
          project_id: project&.id,
          user_id: user&.id,
          namespace_id: namespace&.id,
          plan_name: namespace&.actual_plan_name,
          feature_enabled_by_namespace_ids: feature_enabled_by_namespace_ids
        ).to_context

        service_ping_context = Tracking::ServicePingContext.new(
          data_source: :redis_hll,
          event: event_name
        ).to_context

        contexts = [standard_context, service_ping_context]
        track_struct_event(event_name, category, contexts: contexts, additional_properties: additional_properties)
      end

      def track_struct_event(event_name, category, contexts:, additional_properties:)
        category ||= 'InternalEventTracking'
        tracker = Gitlab::Tracking.tracker
        tracker.event(category, event_name, context: contexts, **additional_properties)
      rescue StandardError => error
        Gitlab::ErrorTracking
          .track_and_raise_for_dev_exception(error, snowplow_category: category, snowplow_action: event_name)
      end

      def send_application_instrumentation_event(event_name, additional_properties, kwargs)
        return if gitlab_sdk_client.nil?

        user = kwargs[:user]

        gitlab_sdk_client.identify(user&.id)

        tracked_attributes = { project_id: kwargs[:project]&.id, namespace_id: kwargs[:namespace]&.id }
        tracked_attributes[:additional_properties] = additional_properties unless additional_properties.empty?
        gitlab_sdk_client.track(event_name, tracked_attributes)
      end

      def create_early_access_program_event(event_name, category, event_label, user)
        return if user.nil? || !user.user_preference.early_access_event_tracking?

        ::EarlyAccessProgram::TrackingEvent.create(
          user: user, event_name: event_name.to_s, event_label: event_label, category: category
        )
      end

      def gitlab_sdk_client
        app_id = ENV['GITLAB_ANALYTICS_ID']
        host = ENV['GITLAB_ANALYTICS_URL']

        return unless app_id.present? && host.present?

        buffer_size = Feature.enabled?(:internal_events_batching) ? SNOWPLOW_EMITTER_BUFFER_SIZE : DEFAULT_BUFFER_SIZE
        GitlabSDK::Client.new(app_id: app_id, host: host, buffer_size: buffer_size)
      end
      strong_memoize_attr :gitlab_sdk_client
    end
  end
end
