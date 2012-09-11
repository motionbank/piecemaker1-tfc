class DropSubscene < ActiveRecord::Migration
  def up
    drop_table :sub_scenes
    drop_table :videos
    drop_table :notes
    drop_table :accounts
    drop_table :setup_configurations
  end

  def down
  end
end
