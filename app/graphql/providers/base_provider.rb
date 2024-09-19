# frozen_string_literal: true

module Providers
  class BaseProvider
    class << self
      def provide(name, proc = nil, milestone: nil, &block)
        provided_fields[name] = { milestone: milestone }

        raise ArgumentError, "Cannot provide both a Proc and a block" if proc && block

        implementation = proc || block

        define_method(name) do |*args|
          instance_exec(*args, &implementation)
        end
      end

      def provided_fields
        @provided_fields ||= {}
      end
    end

    def initialize(current_user: nil, group: nil, project: nil)
      @current_user = current_user
      @project = project
      @group = group || project&.group

      @project_or_group = @project || @group
    end

    private

    attr_reader :current_user, :group, :project, :project_or_group
  end
end
