# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Todos::Snooze, feature_category: :notifications do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:current_user) { create(:user, developer_of: project) }
  let_it_be(:author) { create(:user) }
  let_it_be(:todo) { create(:todo, user: current_user, author: author, state: :pending, target: issue) }
  let_it_be(:other_user) { create(:user) }
  let_it_be(:other_user_todo) { create(:todo, user: other_user, author: author, state: :pending) }

  let(:mutation) { described_class.new(object: nil, context: query_context, field: nil) }

  specify { expect(described_class).to require_graphql_authorizations(:update_todo) }

  describe '#resolve' do
    let_it_be(:snooze_until) { Time.utc(2024, 9, 12, 19, 0, 0) }

    it 'returns the todo' do
      result = snooze_mutation(todo, snooze_until)
      todo = result[:todo]

      expect(todo.snoozed_until).to eq(snooze_until)
    end

    it 'raises an error for todos which do not belong to the current user' do
      expect do
        snooze_mutation(other_user_todo, snooze_until)
      end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end
  end

  def snooze_mutation(todo, snooze_until)
    mutation.resolve(id: global_id_of(todo), snooze_until: snooze_until)
  end
end
