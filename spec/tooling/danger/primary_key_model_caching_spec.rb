# frozen_string_literal: true

require 'fast_spec_helper'
require 'gitlab/dangerfiles/spec_helper'

require_relative '../../../tooling/danger/primary_key_model_caching'
require_relative '../../../tooling/danger/project_helper'

RSpec.describe Tooling::Danger::PrimaryKeyModelCaching, feature_category: :tooling do
  include_context "with dangerfile"

  let(:filename) { 'spec/foo_spec.rb' }
  let(:fake_danger) { DangerSpecHelper.fake_danger }
  let(:fake_project_helper) { instance_double('Tooling::Danger::ProjectHelper') }
  let(:context) { fake_danger.new(helper: fake_helper) }

  let(:template) { described_class::SUGGESTION }

  let(:changed_lines) { file_lines.map { |line| "+#{line}" } }

  subject(:primary_key_model_caching) { described_class.new(filename, context: context) }

  before do
    allow(context).to receive(:project_helper).and_return(fake_project_helper)
    allow(context.helper).to receive(:changed_lines).with(filename).and_return(changed_lines)
    allow(context.project_helper).to receive(:file_lines).and_return(file_lines)
  end

  context 'when the concern include is present' do
    let(:file_lines) do
      <<~RUBY.split("\n")
        # frozen_string_literal: true
        include Gitlab::CachePrimaryKeyLookupResult
      RUBY
    end

    it 'adds comment once' do
      expect(context).to receive(:markdown).with("\n#{template}".chomp, file: filename, line: 2)

      primary_key_model_caching.suggest
    end
  end

  context 'when the concern include is not present' do
    let(:file_lines) do
      <<~RUBY.split("\n")
        # frozen_string_literal: true
        include FooBar
      RUBY
    end

    it 'does not add the comment' do
      expect(context).not_to receive(:markdown)

      primary_key_model_caching.suggest
    end
  end
end
