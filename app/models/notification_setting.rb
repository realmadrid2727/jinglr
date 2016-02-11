class NotificationSetting < ActiveRecord::Base
  belongs_to :user
  
  def update_all(params)
    (NotificationSetting.user_jingles_field_list + NotificationSetting.jingles_field_list).each do |n|
      params[n].blank? ? send("#{n}=", false) : send("#{n}=", true)
    end
    save
  end
  
  
  class << self
    def user_jingles_field_list
      [
        :email_jingle_comments,
        :email_jingle_likes,
        :email_jingle_merge,
        :email_jingle_accept,
        :email_jingle_decline,
        :email_jingle_origin,
      ]
    end
    
    def jingles_field_list
      [
        :email_jingle_update
      ]
    end
  end
end
