class DropNotes < ActiveRecord::Migration
  def up
    drop_table :notes
    drop_table :videos
  end

  def down
  end
end
