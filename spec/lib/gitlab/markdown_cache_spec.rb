# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::MarkdownCache, feature_category: :team_planning do
  it 'returns proper latest_cached_markdown_version' do
    stub_application_setting(local_markdown_version: 2)

    expect(described_class.latest_cached_markdown_version).to eq described_class::CACHE_COMMONMARK_VERSION_SHIFTED | 2
  end
end
