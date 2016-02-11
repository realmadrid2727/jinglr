class JingleComment < ActiveRecord::Base
  include Extends::FollowJingle
  include Extends::NotificationJingle
  include PublicActivity::Model
  
  belongs_to :jingle
  belongs_to :user
  
  tracked owner: ->(controller, model) { model && model.user },
          recipient: ->(controller, model) { model && model.jingle.user }
  
  validates :desc, length: { in: 1..APP_CONFIG["comment_maxlength"] }
  
  after_create  :increment_jingle_comments_count,
                :add_notification,
                :notify_followers
  before_destroy :decrement_jingle_comments_count,
                 :remove_notification,
                 :unfollow_jingle
  
  def too_much_spam?
    user.comments.where(
      "created_at > ?", (Time.now - 30.seconds)
    ).count > 2 ? true : false
  end
  
  def dupe?
    !user.comments.blank? && user.comments.last.desc == self.desc ? true : false
  end
  
  #############
  # Callbacks #
  #############
  def increment_jingle_comments_count
    jingle.update_attribute(:jingle_comments_count, jingle.jingle_comments_count + 1)
  end
  
  def decrement_jingle_comments_count
    jingle.update_attribute(:jingle_comments_count, jingle.jingle_comments_count - 1)
  end
end
