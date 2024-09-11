# frozen_string_literal: true

FactoryBot.define do
  factory :known_key_fingerprints, class: 'KnownKeyFingerprint' do
    sequence(:fingerprint) { |n| "fingerprint-#{n}" }
  end
end
