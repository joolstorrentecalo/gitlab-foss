# frozen_string_literal: true

class KnownKeyFingerprint < ApplicationRecord # rubocop: disable Gitlab/NamespacedClass, Gitlab/BoundedContexts -- Some reason
  validates :fingerprint, uniqueness: true
end
