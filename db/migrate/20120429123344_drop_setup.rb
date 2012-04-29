class DropSetup < ActiveRecord::Migration
  def up
    drop_table :setup_configurations
  end

  def down
  end
end
