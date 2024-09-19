# frozen_string_literal: true

require 'rubocop_spec_helper'
require_relative '../../../../rubocop/cop/background_migration/migrate_int_columns_to_bigint'

RSpec.describe RuboCop::Cop::BackgroundMigration::MigrateIntColumnsToBigint, feature_category: :database do
  let(:table) { 'users' }
  let(:int_ids) { %w[id created_by_id managing_group_id] }
  let(:integer_ids_converted_to_bigint_in_schema) { { table => int_ids } }

  before do
    allow(cop).to receive(:table_int_ids).and_return(integer_ids_converted_to_bigint_in_schema)
  end

  context 'for non migrations' do
    before do
      allow(cop).to receive(:in_migration?).and_return(false)
    end

    it 'does not throw any offense' do
      expect_no_offenses(<<~RUBY)
        class BackfillBigintColumn < Gitlab::Database::Migration[2.1]
          restrict_gitlab_migration gitlab_schema: :gitlab_main

          def up
            backfill_conversion_of_integer_to_bigint(:users, :id, sub_batch_size: 200)
          end

          def down
            revert_backfill_conversion_of_integer_to_bigint(:users, :id)
          end
        end
      RUBY
    end
  end

  context 'for migrations' do
    before do
      allow(cop).to receive(:in_migration?).and_return(true)
      allow(cop).to receive(:version).and_return(version)
    end

    let(:msg) { format(described_class::MSG, version: version, table: table, pending_int_ids: pending_int_ids) }
    let(:version) { 20240830183434 }

    context 'with backfills on table with pending int IDs' do
      context 'with params passed as direct values, for a single column' do
        let(:pending_int_ids) { 'created_by_id, managing_group_id' }

        it 'throws an offense' do
          expect_offense(<<~RUBY)
            class BackfillBigintColumn < Gitlab::Database::Migration[2.1]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
              restrict_gitlab_migration gitlab_schema: :gitlab_main

              def up
                backfill_conversion_of_integer_to_bigint(:users, :id, sub_batch_size: 200)
              end

              def down
                revert_backfill_conversion_of_integer_to_bigint(:users, :id)
              end
            end
          RUBY
        end
      end

      context 'with params passed as direct values, for multiple columns' do
        let(:pending_int_ids) { 'managing_group_id' }

        it 'throws an offense' do
          expect_offense(<<~RUBY)
            class BackfillBigintColumn < Gitlab::Database::Migration[2.1]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
              restrict_gitlab_migration gitlab_schema: :gitlab_main

              def up
                backfill_conversion_of_integer_to_bigint(:users, %i[id created_by_id], sub_batch_size: 200)
              end

              def down
                revert_backfill_conversion_of_integer_to_bigint(:users, %i[id created_by_id])
              end
            end
          RUBY
        end
      end

      context 'with params passed as constants, for single column' do
        let(:pending_int_ids) { 'created_by_id, managing_group_id' }

        it 'throws an offense' do
          expect_offense(<<~RUBY)
            class BackfillBigintColumn < Gitlab::Database::Migration[2.1]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}

              restrict_gitlab_migration gitlab_schema: :gitlab_main

              TABLE = :users
              COLUMN = :id

              def up
                backfill_conversion_of_integer_to_bigint(TABLE, COLUMN, sub_batch_size: 200)
              end

              def down
                revert_backfill_conversion_of_integer_to_bigint(TABLE, COLUMN)
              end
            end
          RUBY
        end

        context 'with params passed as constants, for multiple columns' do
          let(:pending_int_ids) { 'managing_group_id' }

          it 'throws an offense' do
            expect_offense(<<~RUBY)
              class BackfillBigintColumn < Gitlab::Database::Migration[2.1]
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
                restrict_gitlab_migration gitlab_schema: :gitlab_main

                TABLE = :users
                COLUMN = %i[id created_by_id]

                def up
                  backfill_conversion_of_integer_to_bigint(TABLE, COLUMN, sub_batch_size: 200)
                end

                def down
                  revert_backfill_conversion_of_integer_to_bigint(TABLE, COLUMN)
                end
              end
            RUBY
          end
        end
      end

      it 'does not throw an offense on backfilling table with all its int IDs' do
        expect_no_offenses(<<~RUBY)
          class BackfillBigintColumn < Gitlab::Database::Migration[2.1]
            restrict_gitlab_migration gitlab_schema: :gitlab_main

            TABLE = #{table}
            COLUMN = #{int_ids}

            def up
              backfill_conversion_of_integer_to_bigint(TABLE, COLUMN, sub_batch_size: 200)
            end

            def down
              revert_backfill_conversion_of_integer_to_bigint(TABLE, COLUMN)
            end
          end
        RUBY
      end

      it 'does not throw an offense on backfilling table without any int IDs' do
        expect_no_offenses(<<~RUBY)
          class BackfillBigintColumn < Gitlab::Database::Migration[2.1]
            restrict_gitlab_migration gitlab_schema: :gitlab_main

            TABLE = :projects
            COLUMN = :id

            def up
              backfill_conversion_of_integer_to_bigint(TABLE, COLUMN, sub_batch_size: 200)
            end

            def down
              revert_backfill_conversion_of_integer_to_bigint(TABLE, COLUMN)
            end
          end
        RUBY
      end
    end
  end
end
