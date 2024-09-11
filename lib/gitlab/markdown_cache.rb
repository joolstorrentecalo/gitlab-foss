# frozen_string_literal: true

module Gitlab
  module MarkdownCache
    # Increment this number to invalidate cached HTML from Markdown documents.
    # Even when reverting an MR, we should increment this because we only
    # persist the cache when the new version is higher.
    #
    # Changing this value puts strain on the database, as every row with
    # cached markdown needs to be updated. As a result, avoid changing
    # this if the change to the renderer output is a new feature or a
    # minor bug fix.
    # See: https://gitlab.com/gitlab-org/gitlab/-/issues/330313
    CACHE_COMMONMARK_VERSION       = 33
    CACHE_COMMONMARK_VERSION_START = 10
    CACHE_COMMONMARK_VERSION_SHIFTED = CACHE_COMMONMARK_VERSION << 16

    BaseError = Class.new(StandardError)
    UnsupportedClassError = Class.new(BaseError)

    def self.latest_cached_markdown_version
      settings = Gitlab::CurrentSettings.current_application_settings

      CACHE_COMMONMARK_VERSION_SHIFTED | settings.local_markdown_version
    end
  end
end
