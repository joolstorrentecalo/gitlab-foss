# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe DeleteBulkImportEntitiesWithoutProjectIdOrNamespaceId, feature_category: :importers do
  let!(:namespace) { table(:namespaces).create!(name: 'namespace', path: 'namespace') }
  let!(:bulk_import_entities_table) { table(:bulk_import_entities) }
  let!(:project) { table(:projects).create!(namespace_id: namespace.id, project_namespace_id: namespace.id) }

  let(:user) do
    table(:users).create!(name: 'test', email: 'example.user@gitlab.com', projects_limit: 5)
  end

  let(:bulk_import) do
    table(:bulk_imports).create!(user_id: user.id, source_type: 0, status: 0)
  end

  let!(:bulk_import_entity_without_project_or_namespace) do
    bulk_import_entities_table.create!(
      bulk_import_id: bulk_import.id, project_id: nil, namespace_id: nil, source_type: 0, status: 1,
      source_full_path: "path", destination_namespace: "dest_path1", destination_name: "dest_name1"
    )
  end

  let!(:bulk_import_entity_with_project) do
    bulk_import_entities_table.create!(
      bulk_import_id: bulk_import.id, project_id: project.id, source_type: 0, status: 1,
      source_full_path: "path", destination_namespace: "dest_path2", destination_name: "dest_name2"
    )
  end

  let!(:bulk_import_entity_with_namespace) do
    bulk_import_entities_table.create!(
      bulk_import_id: bulk_import.id, namespace_id: namespace.id, source_type: 0, status: 1,
      source_full_path: "path", destination_namespace: "dest_path2", destination_name: "dest_name2"
    )
  end

  describe '#up' do
    it 'deletes bulk_import_entities without a project_id or namespace_id' do
      migrate!

      expect(bulk_import_entities_table.where(project_id: nil, namespace_id: nil)).to be_empty
      expect(bulk_import_entities_table.where(project_id: project.id)).not_to be_empty
      expect(bulk_import_entities_table.where(namespace_id: namespace.id)).not_to be_empty
    end
  end
end
