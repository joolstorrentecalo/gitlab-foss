# frozen_string_literal: true

module CycleAnalyticsParams
  extend ActiveSupport::Concern

  def options(params)
    @options ||= { from: start_date(cycle_analytics_params), current_user: current_user }
  end

  def start_date(params)
    case params[:start_date]
    when '7'
      7.days.ago
    when '30'
      30.days.ago
    else
      90.days.ago
    end
  end

  def cycle_analytics_params
    return {} unless params[:cycle_analytics].present?

    params[:cycle_analytics].permit(:start_date)
  end
end
