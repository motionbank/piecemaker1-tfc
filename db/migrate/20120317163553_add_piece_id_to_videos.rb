class AddPieceIdToVideos < ActiveRecord::Migration
  def up
    add_column :videos, :piece_id, :integer
  end

  def down
  end
end