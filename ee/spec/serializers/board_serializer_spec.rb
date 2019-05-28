# frozen_string_literal: true

require 'spec_helper'

describe BoardSerializer do
  let(:resource) { create(:board) }
  let(:json_entity) do
    described_class.new
      .represent(resource, serializer: serializer)
      .with_indifferent_access
  end

  context 'serialization' do
    let(:serializer) { 'board' }

    it 'matches issue_sidebar_extras json schema' do
      expect(json_entity).to match_schema('entities/board_simple', dir: 'ee')
    end
  end
end
