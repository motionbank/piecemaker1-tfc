class DropUnusedTables < ActiveRecord::Migration
  def up
    drop_table :archive_snapshots
    drop_table :assemblages
    drop_table :block_undos
    drop_table :block_redos
    drop_table :blocklists
    drop_table :blocks
    drop_table :cueings
    drop_table :performances
    drop_table :performers
    drop_table :scenes
    drop_table :showings
    drop_table :tracks
    drop_table :video_recordings
  end

  def down
  end
end
