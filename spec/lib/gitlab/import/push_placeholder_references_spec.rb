# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Import::PushPlaceholderReferences, feature_category: :importers do
  let_it_be(:namespace) { create(:namespace) }

  let(:import_type) { 'github' }
  let(:source_hostname) { 'github.com' }
  let(:source_name) { nil } # github PR responses do not include `name` for users.
  let(:source_username) { 'a_pry_contributor' }
  let(:source_user_identifier) { '1234' }
  let(:project) { create(:project, namespace: namespace) }
  let(:issue) { create(:issue, project: project) }
  let(:import_state) { create(:import_state, :started, project: project) }
  let(:user_reference) { :author_id }

  let(:source_user) do
    create(:import_source_user,
      import_type: import_type,
      source_hostname: source_hostname,
      source_name: source_name,
      source_username: source_username,
      source_user_identifier: source_user_identifier,
      namespace: namespace
    )
  end

  describe '#push_references' do
    it 'calls the push service' do
      project.save!
      import_state.save!
      source_user.save!

      expect(::Import::PlaceholderReferences::PushService)
        .to receive(:from_record)
        .with(
          import_source: import_type,
          import_uid: project.import_state.id,
          record: issue,
          source_user: source_user,
          user_reference_column: user_reference
        ).and_call_original

      result = described_class.push_references(
        source_user_identifier: source_user_identifier,
        namespace: namespace,
        source_hostname: source_hostname,
        import_type: import_type,
        object: issue,
        user_reference: user_reference)

      expect(result).to be_success
    end

    context 'when the placeholder user has been reassigned' do
      it 'does not push the reference' do
        source_user.status = Import::SourceUser::STATUSES[:completed]
        source_user.reassign_to_user_id = User.first.id
        source_user.save!

        result = described_class.push_references(
          source_user_identifier: source_user_identifier,
          namespace: namespace,
          source_hostname: source_hostname,
          import_type: import_type,
          object: issue,
          user_reference: user_reference)

        expect(::Import::PlaceholderReferences::PushService).not_to receive(:from_record)
        expect(result).to be(nil)
      end
    end
  end
end
