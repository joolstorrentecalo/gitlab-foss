# frozen_string_literal: true

module API
  module Entities
    class PersonalAccessTokenAdvancedScopes < Grape::Entity
      expose :http_methods, documentation: { type: 'array', example: %w[GET POST] }
      expose :path_string, documentation: { type: 'string', example: '^/api/v4/user$' }
    end
  end
end
