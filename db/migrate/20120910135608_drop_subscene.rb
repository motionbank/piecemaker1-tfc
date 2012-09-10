class DropSubscene < ActiveRecord::Migration
  def up
    drop_table :sub_scenes
    drop_table :videos
    drop_table :notes
  end

  def down
  end
end
