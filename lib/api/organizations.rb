# frozen_string_literal: true

module API
  class Organizations < ::API::Base
    include PaginationParams

    before { authenticate! }

    resource :organizations do
      desc 'Create new organizations'
      params do
        requires :name, types: String
        requires :path, types: :String
        requires :owner_email, types: String, desc: 'Email address'
      end
      post do
        ::Organizations::CreateService.new(current_user: current_user, params: declared_params).execute
      end
    end
  end
end
