class SiteFeedback < ActiveRecord::Base
  belongs_to :category, class_name: "SiteFeedbackCategory"
  belongs_to :user
  
  validates :desc, presence: true
end
