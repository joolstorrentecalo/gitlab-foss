# frozen_string_literal: true

module Ci
  module JobToken
    class Permissions < Ci::ApplicationRecord
      self.table_name = 'ci_job_token_permissions'
    end
  end
end
