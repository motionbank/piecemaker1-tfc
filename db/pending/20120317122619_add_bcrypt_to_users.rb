class AddBcryptToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_digest, :string
    remove_column :users, :performer
    remove_column :users, :last_assemblage_id
  end
end