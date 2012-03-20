class AddAccountIdToUsersEventsVideos < ActiveRecord::Migration
  def change
    add_column :users,      :account_id, :integer
    add_column :events,     :account_id, :integer
    add_column :videos,     :account_id, :integer
    add_column :sub_scenes, :account_id, :integer
  end
end