class ChangeEventColumnName < ActiveRecord::Migration
  def up
    change_table :commands do |t|
      t.rename :event, :event_data
    end
  end

  def down
  end
end
