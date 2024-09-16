# frozen_string_literal: true

module Projects
  module MergeRequests
    class DiffsStreamController < Projects::MergeRequests::ApplicationController
      include ActionController::Live
      include DiffHelper

      urgency :low, [:diffs]

      def diffs
        return render_404 unless ::Feature.enabled?(:rapid_diffs, current_user, type: :wip)

        stream_headers

        diff_options_hash = diff_options
        diff_options_hash[:offset_index] = params[:offset].to_i

        # NOTE: This is a temporary flag to test out the new diff_blobs
        if !!ActiveModel::Type::Boolean.new.cast(params[:diff_blobs])
          stream_diff_blobs(diff_options_hash)
        else
          stream_diff_files(diff_options_hash)
        end

      rescue StandardError => e
        Gitlab::AppLogger.error("Error streaming diffs: #{e.message}")
        response.stream.write e.message
      ensure
        response.stream.close
      end

      private

      def view
        helpers.diff_view
      end

      def stream_diff_blobs(diff_options_hash)
        @merge_request.diffs_for_streaming(diff_options_hash) do |diff_files_batch|
          diff_files_batch.each do |diff_file|
            response.stream.write(render_diff_file(diff_file))
          end
        end
      end

      def stream_diff_files(diff_options_hash)
        @merge_request.diffs_for_streaming(diff_options_hash).diff_files.each do |diff_file|
          response.stream.write(render_diff_file(diff_file))
        end
      end

      def render_diff_file(diff_file)
        render_to_string(
          ::RapidDiffs::DiffFileComponent.new(diff_file: diff_file, parallel_view: view == :parallel),
          layout: false
        )
      end
    end
  end
end
