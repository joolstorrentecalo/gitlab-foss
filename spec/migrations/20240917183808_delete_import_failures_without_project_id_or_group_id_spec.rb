# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe DeleteImportFailuresWithoutProjectIdOrGroupId, feature_category: :importers do
  let!(:namespace) { table(:namespaces).create!(name: 'namespace', path: 'namespace') }
  let!(:import_failures_table) { table(:import_failures) }
  let!(:project) { table(:projects).create!(namespace_id: namespace.id, project_namespace_id: namespace.id) }

  let(:user) do
    table(:users).create!(name: 'test', email: 'example.user@gitlab.com', projects_limit: 5)
  end

  let(:bulk_import) do
    table(:bulk_imports).create!(user_id: user.id, source_type: 0, status: 0)
  end

  let!(:import_failure_without_project_or_group) do
    import_failures_table.create!(project_id: nil, group_id: nil)
  end

  let!(:import_failure_with_project) do
    import_failures_table.create!(project_id: project.id)
  end

  let!(:import_failure_with_group) do
    import_failures_table.create!(group_id: namespace.id)
  end

  describe '#up' do
    it 'deletes import_failures without a project_id or group_id' do
      migrate!

      expect(import_failures_table.where(project_id: nil, group_id: nil)).to be_empty
      expect(import_failures_table.where(project_id: project.id)).not_to be_empty
      expect(import_failures_table.where(group_id: namespace.id)).not_to be_empty
    end
  end
end
