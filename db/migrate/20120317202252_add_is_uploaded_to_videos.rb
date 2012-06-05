class AddIsUploadedToVideos < ActiveRecord::Migration
  def up
    add_column :videos, :is_uploaded, :boolean, :default => false
  end

  def down
    remove_column :videos, :is_uploaded
  end
end