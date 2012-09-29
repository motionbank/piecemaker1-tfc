class DropSubscene < ActiveRecord::Migration
  def up
    drop_table :accounts
    drop_table :notes
    drop_table :setup_configurations
    drop_table :sub_scenes
    drop_table :videos
  end

  def down
  end
end
