# frozen_string_literal: true

module Subscriptions
  class IssuableUserUpdated < BaseSubscription
    include Gitlab::Graphql::Laziness

    payload_type Types::IssuableType

    argument :issuable_id, Types::GlobalIDType[Issuable],
      required: true,
      description: 'ID of the issuable.'

    argument :user_id, Types::GlobalIDType[User],
      required: true,
      description: 'User ID of the todo updated.'

    def authorized?(issuable_id:, user_id:)
      issuable = force(GitlabSchema.find_by_gid(issuable_id))

      unauthorized! unless user_id == current_user.to_global_id
      unauthorized! unless issuable && Ability.allowed?(current_user, :"read_#{issuable.to_ability_name}", issuable)

      true
    end
  end
end
