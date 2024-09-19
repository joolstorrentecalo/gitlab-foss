# frozen_string_literal: true

require_relative 'suggestion'

module Tooling
  module Danger
    class PrimaryKeyModelCaching < Suggestion
      MATCH = %r{include Gitlab::CachePrimaryKeyLookupResult}
      REPLACEMENT = nil
      DOCUMENTATION_LINK = 'https://docs.gitlab.com/ee/development/database_review.html#preparation-when-using-bulk-update-operations'

      SUGGESTION = <<~MESSAGE_MARKDOWN
        **This concern must be used with extreme caution!**

        Unless used with a table with very specific parameters, the use of this
        concern could result in unacceptable stale data reads and affect application
        stability.

        @gitlab-org/database-team **must approve use of this concern**.
      MESSAGE_MARKDOWN
    end
  end
end
