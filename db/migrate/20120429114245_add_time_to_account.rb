class AddTimeToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :time_zone, :string, :default => 'Berlin'
  end
end