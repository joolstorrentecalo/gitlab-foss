# frozen_string_literal: true

require "spec_helper"

RSpec.describe RapidDiffs::Viewers::Text::TextViewComponent, type: :component, feature_category: :code_review_workflow do
  it 'renders columns' do
    render_inline(described_class.new(column_titles: ['Foo']))
    expect(page).to have_selector('th', text: 'Foo')
  end

  it 'renders body' do
    render_inline(described_class.new(column_titles: []).tap { |c| c.with_body { '<div>Body</div>'.html_safe } })
    expect(page).to have_selector('div', text: 'Body')
  end
end
