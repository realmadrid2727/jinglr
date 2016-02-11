class CreateSiteFeedbacks < ActiveRecord::Migration
  def change
    create_table :site_feedbacks do |t|
      t.integer  :user_id
      t.integer  :site_feedback_category_id
      t.text     :desc
      t.timestamps
    end
  end
end
