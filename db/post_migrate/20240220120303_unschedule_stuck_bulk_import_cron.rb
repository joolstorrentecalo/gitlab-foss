# frozen_string_literal: true

class UnscheduleStuckBulkImportCron < Gitlab::Database::Migration[2.2]
  milestone '16.10'
  disable_ddl_transaction!

  def up
    # This is to clean up the cron schedule for BulkImports::StuckImportWorker
    # which was removed in
    # https://gitlab.com/gitlab-org/gitlab/-/merge_requests/143806
    removed_job = Sidekiq::Cron::Job.find('bulk_imports_stuck_import_worker')
    removed_job.destroy if removed_job

    sidekiq_remove_jobs(job_klasses: %w[BulkImports::StuckImportWorker])
  end

  def down
    # This is to remove the cron schedule for a deleted job, so there is no
    # meaningful way to reverse it.
  end
end
