class AddAccountIdToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :account_id, :integer
  end
end