module Extends::NotificationJingle
  # These two primarily work with comments and likes
  def add_notification
    unless user_id == jingle.user_id
      Notification.create(
        target_id: jingle_id,
        target_type: "Jingle",
        notice_id: id,
        notice_type: self.class,
        user_id: jingle.user_id,
        notifier_id: user_id
      )
    end
  end
  
  def remove_notification
    notice = Notification.where({
      target_id: jingle_id,
      target_type: "Jingle",
      notice_id: id,
      notice_type: self.class,
      user_id: jingle.user_id,
      notifier_id: user_id
    }).first
    notice.blank? ? true : notice.destroy
  end
  
  # This works with jingles
  def notify_original_creators
    origins.each do |o|
      unless o.parent.user_id == o.jingle.user_id
        Notification.create(
          target_id: o.parent_id,
          target_type: "Jingle",
          notice_id: o.jingle_id,
          notice_type: "JingleOrigin",
          user_id: o.jingle.user_id,
          notifier_id: user_id
        )
      end
    end
  end
  
  def notify_followers(notice_id = id, ignore_user_id = nil)
    jingle.followers.each do |follower|
      # Ignore the user who is notifying, and a user ID supplied to the method (if any)
      unless follower.id == user_id || follower.id == jingle.user_id || (!ignore_user_id.nil? && follower.id == ignore_user_id)
        Notification.create(
          target_id: jingle.id,
          target_type: "JingleUpdate",
          notice_id: notice_id,
          notice_type: self.class,
          user_id: follower.id,
          notifier_id: user_id
        )
      end
    end
  end
end