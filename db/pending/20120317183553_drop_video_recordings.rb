class DropVideoRecordings < ActiveRecord::Migration
  def up
    drop_table :video_recordings
  end

  def down
  end
end