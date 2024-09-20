# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      # Tracking of load balancing state per user session.
      #
      # A session starts at the beginning of a request and ends once the request
      # has been completed. Sessions can be used to keep track of what hosts
      # should be used for queries.
      class Session
        CACHE_KEY = :gitlab_load_balancer_session

        DEFAULT_KEY = :default

        def self.current
          RequestStore[CACHE_KEY] ||= new
        end

        def self.clear_session
          RequestStore.delete(CACHE_KEY)
        end

        def self.without_sticky_writes(&block)
          current.ignore_writes(&block)
        end

        def initialize
          @ignore_writes = false
          @use_replicas_for_read_queries = false
          @fallback_to_replicas_for_ambiguous_queries = false

          @use_primary_map = { DEFAULT_KEY => false }
          @performed_write_map = { DEFAULT_KEY => false }
        end

        def use_primary?(db)
          lookup_map(@use_primary_map, db)
        end

        alias_method :using_primary?, :use_primary?

        def use_primary!(db = nil)
          @use_primary_map[key(db)] = true
        end

        def use_primary(&blk)
          used_primary = @use_primary_map[DEFAULT_KEY]
          @use_primary_map[DEFAULT_KEY] = true

          yield
        ensure
          @use_primary_map[DEFAULT_KEY] = used_primary || performed_write?(DEFAULT_KEY)

          # We need to update use_primary status of indvidual db as a db-specific .write! call
          # could be performed within the use_primary(&blk) scope.
          @performed_write_map.each do |k, v|
            next if k == DEFAULT_KEY || v.nil?

            @use_primary_map[k] = @use_primary_map.fetch(k, false) || v
          end
        end

        def ignore_writes(&block)
          @ignore_writes = true

          yield
        ensure
          @ignore_writes = false
        end

        # Indicates that the read SQL statements from anywhere inside this
        # blocks should use a replica, regardless of the current primary
        # stickiness or whether a write query is already performed in the
        # current session. This interface is reserved mostly for performance
        # purpose. This is a good tool to push expensive queries, which can
        # tolerate the replica lags, to the replicas.
        #
        # Write and ambiguous queries inside this block are still handled by
        # the primary.
        def use_replicas_for_read_queries(&blk)
          previous_flag = @use_replicas_for_read_queries
          @use_replicas_for_read_queries = true
          yield
        ensure

          @use_replicas_for_read_queries = previous_flag
        end

        def use_replicas_for_read_queries?
          @use_replicas_for_read_queries == true
        end

        # Indicate that the ambiguous SQL statements from anywhere inside this
        # block should use a replica. The ambiguous statements include:
        # - Transactions.
        # - Custom queries (via exec_query, execute, etc.)
        # - In-flight connection configuration change (SET LOCAL statement_timeout = 5000)
        #
        # This is a weak enforcement. This helper incorporates well with
        # primary stickiness:
        # - If the queries are about to write
        # - The current session already performed writes
        # - It prefers to use primary, aka, use_primary or use_primary! were called
        def fallback_to_replicas_for_ambiguous_queries(&blk)
          previous_flag = @fallback_to_replicas_for_ambiguous_queries
          @fallback_to_replicas_for_ambiguous_queries = true
          yield
        ensure
          @fallback_to_replicas_for_ambiguous_queries = previous_flag
        end

        def fallback_to_replicas_for_ambiguous_queries?(db)
          @fallback_to_replicas_for_ambiguous_queries == true && !use_primary?(db) && !performed_write?(db)
        end

        def write!(db)
          @performed_write_map[key(db)] = true

          return if @ignore_writes

          use_primary!(db)
        end

        def performed_write?(db = nil)
          lookup_map(@performed_write_map, db)
        end

        def lookup_map(hash, db)
          return hash[DEFAULT_KEY] unless db

          # checks default key is db is specified since the
          # default key may have been set at a outer scope
          hash.fetch(db, false) || hash[DEFAULT_KEY]
        end

        def key(db)
          db || DEFAULT_KEY
        end
      end
    end
  end
end
