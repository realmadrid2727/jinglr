class CreateUserDetails < ActiveRecord::Migration
  def change
    create_table :user_details do |t|
      t.integer  :user_id
      t.string   :name
      t.string   :location
      t.string   :website
      t.string   :bio
      t.string   :track_mixer_list
      t.timestamps
    end
  end
end
