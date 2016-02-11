class SiteFeedbackCategory < ActiveRecord::Base
  has_many :feedbacks, class_name: "SiteFeedback"
end
