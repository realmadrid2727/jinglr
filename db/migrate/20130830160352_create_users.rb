class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :username
      t.integer  :uid
      t.string   :name
      t.string   :provider
      t.string   :provider_token
      t.string   :provider_token_secret
      t.integer  :followers_count_cache, null: false, default: 0
      t.integer  :following_count_cache, null: false, default: 0
      t.integer  :jingles_count, null: false, default: 0
      
      t.timestamps
    end
  end
end
