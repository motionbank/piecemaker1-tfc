class AddMoreAccountIds < ActiveRecord::Migration
  def change
    add_column :locations,      :account_id, :integer
    add_column :configurations, :account_id, :integer
    add_column :delayed_jobs,   :account_id, :integer
    add_column :documents,      :account_id, :integer
    add_column :messages,       :account_id, :integer
    add_column :meta_infos,     :account_id, :integer
    add_column :notes,          :account_id, :integer
    add_column :photos,         :account_id, :integer
    add_column :tags,           :account_id, :integer
  end
end
