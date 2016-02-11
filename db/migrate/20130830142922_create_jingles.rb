class CreateJingles < ActiveRecord::Migration
  def change
    create_table :jingles do |t|
      t.integer  :user_id
      t.integer  :parent_id
      t.string   :desc
      t.integer  :jingle_likes_count, null: false, default: 0
      t.integer  :jingle_favorites_count, null: false, default: 0
      t.integer  :jingle_comments_count, null: false, default: 0
      t.integer  :jingle_tracks_count, null: false, default: 0
      t.boolean  :active, null: false, default: false
      t.datetime :latest_at
      t.string   :state, null: false, default: "processing"
      t.text     :stat, null: false
      
      t.timestamps
    end
  end
end
