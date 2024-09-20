# frozen_string_literal: true

FactoryBot.define do
  factory :personal_access_token_advanced_scopes, class: 'Authz::PersonalAccessTokenAdvancedScope' do
    association :personal_access_token

    http_methods { ['GET'] }
    path_string { '^/api/v4/$' }

    created_at { Time.current }
    updated_at { Time.current }
  end
end
