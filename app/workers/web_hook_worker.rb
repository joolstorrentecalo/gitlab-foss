# frozen_string_literal: true

class WebHookWorker
  include ApplicationWorker

  sidekiq_options retry: 4, dead: false

  def self.sidekiq_status_enabled?
    false
  end

  def perform(hook_id, data, hook_name)
    hook = WebHook.find(hook_id)
    data = data.with_indifferent_access

    WebHookService.new(hook, data, hook_name).execute
  end
end
