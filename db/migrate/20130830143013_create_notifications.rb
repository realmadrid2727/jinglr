class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer  :user_id
      t.integer  :notifier_id
      t.integer  :target_id
      t.string   :target_type
      t.integer  :notice_id
      t.string   :notice_type
      t.boolean  :viewed, null: false, default: false
      
      t.timestamps
    end
  end
end
