class CreateSiteFeedbackCategories < ActiveRecord::Migration
  def change
    create_table :site_feedback_categories do |t|
      t.string   :name
    end
  end
end
