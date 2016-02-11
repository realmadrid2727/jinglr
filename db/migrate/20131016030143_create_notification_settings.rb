class CreateNotificationSettings < ActiveRecord::Migration
  def change
    create_table :notification_settings do |t|
      t.integer  :user_id
      t.boolean  :email_jingle_comments, default: true
      t.boolean  :email_jingle_likes, default: true
      t.boolean  :email_jingle_merge, default: true
      t.boolean  :email_jingle_decline, default: true
      t.boolean  :email_jingle_accept, default: true
      t.boolean  :email_jingle_origin, default: true
      t.boolean  :email_jingle_update, default: true
      t.timestamps
    end
  end
end
