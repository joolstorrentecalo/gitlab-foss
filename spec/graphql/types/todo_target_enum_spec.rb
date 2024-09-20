# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['TodoTargetEnum'], feature_category: :notifications do
  specify { expect(described_class.graphql_name).to eq('TodoTargetEnum') }

  it 'exposes all the existing todo targets' do
    expect(described_class.values.keys).to include(*%w[COMMIT ISSUE WORKITEM MERGEREQUEST DESIGN ALERT KEY])
  end
end
