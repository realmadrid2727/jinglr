class CreateJingleLikes < ActiveRecord::Migration
  def change
    create_table :jingle_likes do |t|
      t.integer  :user_id
      t.integer  :jingle_id
      
      t.timestamps
    end
  end
end
