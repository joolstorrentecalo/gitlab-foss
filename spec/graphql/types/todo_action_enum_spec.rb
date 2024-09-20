# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['TodoActionEnum'], feature_category: :notifications do
  specify { expect(described_class.graphql_name).to eq('TodoActionEnum') }

  it 'exposes all the existing todo actions' do
    expect(described_class.values.keys).to match_array(%w[assigned mentioned build_failed marked approval_required
      unmergeable directly_addressed merge_train_removed review_requested member_access_requested review_submitted
      okr_checkin_requested added_approver expired])
  end
end
