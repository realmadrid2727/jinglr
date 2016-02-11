class CreateJingleFavorites < ActiveRecord::Migration
  def change
    create_table :jingle_favorites do |t|
      t.integer  :user_id
      t.integer  :jingle_id
      
      t.timestamps
    end
  end
end
