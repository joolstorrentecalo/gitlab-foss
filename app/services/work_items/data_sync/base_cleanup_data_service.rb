# frozen_string_literal: true

module WorkItems
  module DataSync
    class BaseCleanupDataService < BaseService
      def initialize(work_item:, current_user: nil, params: {})
        super(work_item: work_item, target_namespace: nil, current_user: current_user, params: params)
      end

      def execute
        @work_item.widgets.each do |widget|
          handler_class = widget.sync_data_callback_class
          data_handler = handler_class&.new(
            work_item: work_item,
            target_work_item: nil,
            current_user: current_user,
            params: params
          )
          data_handler&.cleanup
        end
      end
    end
  end
end
