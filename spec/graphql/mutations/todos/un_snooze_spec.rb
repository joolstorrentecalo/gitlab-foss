# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Todos::UnSnooze, feature_category: :notifications do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:current_user) { create(:user, developer_of: project) }
  let_it_be(:author) { create(:user) }
  let_it_be(:snoozed_until) { Time.utc(2024, 9, 12, 19, 0, 0) }
  let_it_be(:todo) do
    create(:todo, user: current_user, author: author, state: :pending, target: issue, snoozed_until: snoozed_until)
  end

  let_it_be(:other_user) { create(:user) }
  let_it_be(:other_user_todo) { create(:todo, user: other_user, author: author, state: :pending) }

  let(:mutation) { described_class.new(object: nil, context: query_context, field: nil) }

  specify { expect(described_class).to require_graphql_authorizations(:update_todo) }

  describe '#resolve' do
    it 'returns the todo' do
      result = un_snooze_mutation(todo)
      todo = result[:todo]

      expect(todo.snoozed_until).to eq(nil)
    end

    it 'raises an error for todos which do not belong to the current user' do
      expect { un_snooze_mutation(other_user_todo) }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end
  end

  def un_snooze_mutation(todo)
    mutation.resolve(id: global_id_of(todo))
  end
end
