class ChangeCastingPerformerId < ActiveRecord::Migration
  def up
    change_table :castings do |t|
      t.rename :performer_id, :user_id
    end
  end

  def down
  end
end
