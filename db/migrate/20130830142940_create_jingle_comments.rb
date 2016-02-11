class CreateJingleComments < ActiveRecord::Migration
  def change
    create_table :jingle_comments do |t|
      t.integer  :user_id
      t.integer  :jingle_id
      t.string   :desc
      
      t.timestamps
    end
  end
end
