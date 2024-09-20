# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::BackfillPackagesNugetSymbolsProjectId, feature_category: :package_registry do
  let!(:namespace) { table(:namespaces).create!(name: 'group', path: 'group', type: 'Group') }
  let!(:starting_id) { table(:packages_nuget_symbols).minimum(:id) }
  let!(:end_id) { table(:packages_nuget_symbols).maximum(:id) }
  let!(:migration) do
    described_class.new(
      start_id: starting_id,
      end_id: end_id,
      batch_table: :packages_nuget_symbols,
      batch_column: :id,
      sub_batch_size: 2,
      pause_ms: 0,
      connection: ::ApplicationRecord.connection
    )
  end

  let!(:project) do
    table(:projects).create!(name: 'project', path: 'project', project_namespace_id: namespace.id,
      namespace_id: namespace.id)
  end

  before do
    3.times do |i|
      package = table(:packages_packages).create!(name: "test-#{i}", package_type: 1, project_id: project.id)
      table(:packages_nuget_symbols).create!(size: 1, file: 'package.pdb', package_id: package.id,
        file_path: "/path/#{i}", signature: 'abcd1234', object_storage_key: "/packages/nuget/symbols/#{i}")
    end
  end

  it 'deletes entries with missing `project_id`' do
    expect { migration.perform }
      .to change { table(:packages_nuget_symbols).where(project_id: nil).count }
      .from(3)
      .to(0)
  end
end
