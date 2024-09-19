# frozen_string_literal: true

module Gitlab
  module Git
    class TagPolicy < BasePolicy
      delegate { project }

      condition(:protected_tag) do
        ProtectedTag.protected?(project, @subject.name)
      end

      rule { can?(:admin_tag) }.enable :delete_tag
      rule { protected_tag & ~can?(:maintainer_access) }.prevent :delete_tag

      def project
        @subject.repository.container
      end
    end
  end
end
