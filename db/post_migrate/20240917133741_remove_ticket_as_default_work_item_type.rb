# frozen_string_literal: true

class RemoveTicketAsDefaultWorkItemType < Gitlab::Database::Migration[2.2]
  milestone '17.5'
  disable_ddl_transaction!
  restrict_gitlab_migration gitlab_schema: :gitlab_main_cell

  TICKET_ENUM_VALUE = 8

  class MigrationWorkItemType < MigrationRecord
    self.table_name = 'work_item_types'
  end

  def up
    existing_ticket_work_item_type = MigrationWorkItemType.find_by(base_type: TICKET_ENUM_VALUE)

    return say('Ticket work item type record does not exists, skipping deletion') unless existing_ticket_work_item_type

    existing_ticket_work_item_type.destroy
  end

  def down
    # Adding back TICKET type should be done via a seperate migration
    # https://docs.gitlab.com/ee/development/work_items.html#example-of-adding-a-ticket-work-item
  end
end
