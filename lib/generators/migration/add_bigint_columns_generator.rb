# frozen_string_literal: true

require 'rails/generators/active_record'

module Migration # rubocop:disable Gitlab/BoundedContexts -- Generators can be excluded from the bounded contexts rule
  class AddBigintColumnsGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('templates', __dir__)

    class_option :columns, type: :string, required: true
    class_option :migration_number, type: :string, required: true,
      desc: 'new migration to add bigint columns will use the timestamp before this'

    def create_migration_files
      template(
        'initialize_conversion_of_int_columns_to_bigint.template',
        File.join(
          db_migrate_path,
          "#{migration_number_in_past(migration_number)}_initialize_conversion_of_#{table_name}_to_bigint.rb")
      )

      say <<-MESSAGE.squeeze(' ').strip
        Created the above migration to add corresponding bigint columns and their triggers.
        Next steps:
          1. Ignore the newly created bigint ID columns from the model.
          2. Update your migration (#{migration_number}) to backfill the new bigint ID columns.
      MESSAGE
    end

    private

    def table_name
      name
    end

    def migration_number
      options[:migration_number]
    end

    def integer_columns
      options[:columns].split(', ').join(' ')
    end

    def migration_number_in_past(migration_number)
      (Time.parse(migration_number).utc - 1.second).strftime("%Y%m%d%H%M%S")
    end

    def current_milestone
      Gitlab.current_milestone
    end
  end
end
