# frozen_string_literal: true

# goal of this context: provide an easy process for setting and using the current public organization that is set
# in the middleware for non-feature spec level specs.
RSpec.shared_context 'with current_public_organization setting', shared_context: :metadata do # rubocop:disable RSpec/SharedGroupsMetadata -- We are actually using this for easy metadata setting
  let_it_be(:current_organization, reload: true) { create(:organization, :public, name: 'Current Public Organization') }

  before do
    allow(Current).to receive(:organization).and_return(current_organization)
    allow(Current).to receive(:organization_id).and_return(current_organization.id)
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'with current_public_organization setting', with_current_public_organization: true
end
