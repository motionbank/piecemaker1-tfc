class DropVideoRecordings < ActiveRecord::Migration
  def up
    add_column :videos, :piece_id, :integer
    drop_table :video_recordings
  end

  def down
  end
end