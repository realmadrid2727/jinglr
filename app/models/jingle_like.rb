class JingleLike < ActiveRecord::Base
  include Extends::FollowJingle
  include Extends::NotificationJingle
  include PublicActivity::Model
  
  belongs_to :jingle
  belongs_to :user
  
  tracked owner: ->(controller, model) { model && model.user },
          recipient: ->(controller, model) { model && model.jingle.user }
  
  after_create  :increment_jingle_likes_count,
                :add_notification
  before_destroy :decrement_jingle_likes_count, :remove_notification, :unfollow_jingle
  
  #############
  # Callbacks #
  #############
  def increment_jingle_likes_count
    jingle.update_attribute(:jingle_likes_count, jingle.jingle_likes_count + 1)
  end
  
  def decrement_jingle_likes_count
    jingle.update_attribute(:jingle_likes_count, jingle.jingle_likes_count - 1)
  end
end
