# frozen_string_literal: true

require_relative '../../migration_helpers'

module RuboCop
  module Cop
    module BackgroundMigration
      # Cop to recommend migrating all integer IDs in the table to bigint
      class MigrateIntColumnsToBigint < RuboCop::Cop::Base
        include MigrationHelpers

        MSG = <<-MESSAGE.delete("\n").squeeze(' ').strip
          '%{table}' table still has [%{pending_int_ids}] integer IDs.
          Please run `rails g migration:add_bigint_columns %{table} --columns=%{pending_int_ids} --migration_number=%{version}` to resolve this.
          For more info: https://gitlab.com/gitlab-org/gitlab/-/issues/482470
        MESSAGE

        RESTRICT_ON_SEND = [:backfill_conversion_of_integer_to_bigint].freeze

        def_node_search :backfill_conversion_of_integer_to_bigint?, <<~PATTERN
          (:send nil? :backfill_conversion_of_integer_to_bigint ...)
        PATTERN

        def_node_matcher :backfill_conversion_of_integer_to_bigint_node, <<~PATTERN
          `(send nil? :backfill_conversion_of_integer_to_bigint $_ $_ ...)
        PATTERN

        def_node_matcher :constant_value, <<~PATTERN
          `(casgn nil? %const_name ($_ $...))
        PATTERN

        def on_class(node)
          return unless in_migration?(node) && backfill_conversion_of_integer_to_bigint?(node)

          table_name_node, column_name_node = backfill_conversion_of_integer_to_bigint_node(node)

          table_name = fetch_value(node, table_name_node)

          columns = Array(fetch_value(node, column_name_node)).map(&:to_s)
          pending_int_ids = int_ids_in_table(table_name.to_s).map(&:to_s) - columns

          return unless pending_int_ids.present?

          add_offense(
            node,
            message: format(MSG, table: table_name, pending_int_ids: pending_int_ids.join(', '), version: version(node))
          )
        end

        private

        def fetch_value(node, value_node)
          return fetch_const_value(node, value_node) if value_node.type == :const

          value_node.type == :array ? value_node.values.map(&:value) : value_node.value
        end

        def fetch_const_value(node, value_node)
          type, value = constant_value(node, const_name: value_node.const_name.to_sym)
          return value[0] unless type == :array

          value.map(&:value)
        end

        def int_ids_in_table(table_name)
          table_int_ids[table_name] || []
        end

        def table_int_ids
          @table_int_ids ||= YAML.safe_load_file(
            File.join('db/integer_ids_converted_to_bigint_in_schema.yml')
          )
        end
      end
    end
  end
end
