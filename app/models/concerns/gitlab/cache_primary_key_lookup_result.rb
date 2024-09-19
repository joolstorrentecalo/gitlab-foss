# frozen_string_literal: true

module Gitlab
  module CachePrimaryKeyLookupResult
    extend ActiveSupport::Concern

    included do
      after_save :delete_cache_entry
    end

    class_methods do
      def primary_key_lookup_enabled?
        Feature.enabled?(:cache_primary_key_lookup_result, Feature.current_request)
      end

      def class_cache_fingerprint
        @class_cache_fingerprint ||=
          Digest::SHA256.hexdigest([name, methods.sort.to_s, columns_hash.sort.to_s].to_s).slice(0, 16)
      end

      def function_lookup_matcher
        @function_lookup_matcher ||=
          /FROM find_#{table_name}_by_id\((\d+)\) AS #{table_name} WHERE \("#{table_name}"."id" IS NOT NULL\) LIMIT 1/
      end

      def primary_key_matcher
        @primery_key_matcher ||= /FROM "#{table_name}" WHERE "#{table_name}"."id" = (\d+) LIMIT 1/
      end

      def find_by_sql(sql, binds = [], preparable: nil, &block)
        return super unless primary_key_lookup_enabled?

        primary_key = primary_key_lookup(sql)
        return super unless primary_key

        Rails.cache.fetch(primary_key_lookup_cache_key(primary_key), expires_in: primary_key_lookup_cache_expiration) do
          super
        end
      end

      def primary_key_lookup_cache_key(id)
        "#{table_name}/#{class_cache_fingerprint}/#{id}"
      end

      def cache_expiration_times
        @cache_expiration_times ||= begin
          setting = ApplicationSetting.current.primary_key_cache_timeouts
          setting.is_a?(Hash) ? setting : {}
        rescue NoMethodError
          {}
        end
      end

      def primary_key_lookup_cache_expiration
        cache_expiration_times[table_name]&.second || 60.seconds
      end

      def find(*args)
        return super unless primary_key_lookup_enabled? && args.length == 1 && args.first.is_a?(Integer)

        id = args.first
        Rails.cache.fetch(primary_key_lookup_cache_key(id), expires_in: primary_key_lookup_cache_expiration) do
          super(id)
        end
      end

      def primary_key_lookup(sql)
        return unless sql.is_a?(String)

        function_lookup_match = function_lookup_matcher.match(sql)
        return function_lookup_match[1] if function_lookup_match

        primary_key_match = primary_key_matcher.match(sql)
        primary_key_match[1] if primary_key_match
      end
    end

    def delete_cache_entry
      Rails.cache.delete(self.class.base_class.primary_key_lookup_cache_key(id))
    end

    def primary_key_lookup_cache_key
      self.class.base_class.primary_key_lookup_cache_key(id)
    end
  end
end
