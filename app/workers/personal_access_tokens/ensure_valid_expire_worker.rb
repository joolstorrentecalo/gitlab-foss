# frozen_string_literal: true

# Worker to ensure expires_at on PersonalAccessTokens is within policy

module PersonalAccessTokens # rubocop: disable Gitlab/BoundedContexts -- Some reason
  class EnsureValidExpireWorker # rubocop: disable Scalability/IdempotentWorker -- Some reason
    include ApplicationWorker

    data_consistency :always # rubocop: disable SidekiqLoadBalancing/WorkerDataConsistency -- Some reason

    include CronjobQueue

    NUMBER_OF_BATCHES = 50
    BATCH_SIZE = 200
    PAUSE_SECONDS = 0.25
    MAX_EXPIRY_DAYS = 365
    NOT_BEFORE = "2023-09-27"

    def perform
      with_context(caller_id: self.class.name.to_s) do
        NUMBER_OF_BATCHES.times do
          result = PersonalAccessToken.connection.execute(update_query)

          break if result.cmd_tuples == 0

          sleep(PAUSE_SECONDS)
        end
      end
    end

    private

    def update_query
      <<~SQL
        UPDATE personal_access_tokens
        SET expires_at = greatest(created_at + INTERVAL '#{MAX_EXPIRY_DAYS} days', DATE '#{NOT_BEFORE}')
        WHERE id IN (#{tokens.to_sql}) AND (expires_at IS NULL or (expires_at > created_at + INTERVAL '#{MAX_EXPIRY_DAYS} days' and expires_at > DATE '#{NOT_BEFORE}'));
      SQL
    end

    def tokens
      PersonalAccessToken.active.select(:id)
    end
  end
end
