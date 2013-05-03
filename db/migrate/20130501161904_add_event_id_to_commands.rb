class AddEventIdToCommands < ActiveRecord::Migration
  def change
    add_column :commands, :event_id, :integer
  end
end
