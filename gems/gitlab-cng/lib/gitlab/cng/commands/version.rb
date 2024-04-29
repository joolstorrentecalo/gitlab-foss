# frozen_string_literal: true

module Gitlab
  module Cng
    module Commands
      class Version < Thor
        desc 'version', 'Prints cng orchestrator version'
        def version
          puts Cng::VERSION
        end
      end
    end
  end
end
