# frozen_string_literal: true

module Gitlab
  module Diff
    class RenderedCache
      include Gitlab::Utils::Gzip
      include Gitlab::Utils::StrongMemoize

      EXPIRATION = 8.hour
      VERSION = 1 # Bump this if there are changes in rendered markup

      delegate :diffable,     to: :diff_collection
      delegate :diff_options, to: :diff_collection

      def initialize(diff_collection, compress: false, compress_offset: 0, limit: 100)
        @diff_collection = diff_collection
        @compress = compress
        @compress_offset = compress_offset
        @limit = limit&.to_i || 100
        @files_to_cache = {}

        yield(self)
        write
      end

      def fetch(diff_file)
        cached_file_content = cached_content[diff_file.file_path]

        return cached_file_content.html_safe if cached_file_content.present?

        # If file wasn't cached, add it to the list that will be cached when
        # `#write` is called.
        return yield unless file_paths.include?(diff_file.file_path)

        @files_to_cache[diff_file.file_path] = yield
      end

      def write
        return if files_to_cache.empty?

        with_redis do |redis|
          redis.pipelined do |pipeline|
            files_to_cache.each do |file_path, content|
              pipeline.hset(
                cache_key,
                file_path,
                compress(file_path, content)
              )

              # HSETs have to have their expiration date manually updated
              pipeline.expire(cache_key, EXPIRATION)
            end
          end
        end
      end

      private

      attr_reader :diff_collection, :compress_offset, :limit, :files_to_cache

      def compress?(file_path)
        @compress && file_paths_to_compress.include?(file_path)
      end

      def cached_content
        return {} unless file_paths.any?

        results, _ = with_redis do |redis|
          redis.pipelined do |pipeline|
            pipeline.hmget(cache_key, file_paths)
            pipeline.expire(cache_key, EXPIRATION)
          end
        end

        results.map! do |result|
          unless result.nil?
            gzip_decompress(result.force_encoding(Encoding::UTF_8))
          end
        end

        file_paths.zip(results).to_h
      end
      strong_memoize_attr :cached_content

      def file_paths
        diff_collection.raw_diff_files.collect(&:file_path).take(limit)
      end
      strong_memoize_attr :file_paths

      def file_paths_to_compress
        file_paths.drop(compress_offset)
      end
      strong_memoize_attr :file_paths_to_compress

      def compress(file_path, data)
        return data unless compress?(file_path)

        gzip_compress(data)
      end

      def cache_key
        strong_memoize(:redis_key) do
          diff_options_key = OpenSSL::Digest::SHA256.hexdigest(diff_options.to_json)

          [
            'rendered-diffs',
            diffable.cache_key,
            diffable.patch_id_sha,
            diff_options_key,
            @compress,
            compress_offset,
            limit,
            VERSION
          ].join(":")
        end
      end
      strong_memoize_attr :cache_key

      def with_redis(&block)
        Redis::Cache.with(&block) # rubocop:disable CodeReuse/ActiveRecord
      end
    end
  end
end
