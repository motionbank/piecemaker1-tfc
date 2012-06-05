class RemoveColumnsFromVideos < ActiveRecord::Migration
  def up
     remove_column :videos, :fn_arch
     remove_column :videos, :fn_local
     remove_column :videos, :fn_s3
     remove_column :videos, :vid_type
  end

  def down
  end
end