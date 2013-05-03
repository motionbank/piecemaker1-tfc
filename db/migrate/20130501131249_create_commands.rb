class CreateCommands < ActiveRecord::Migration
  def change
    create_table :commands do |t|

      t.timestamps
      t.text :event
    end
  end
end
