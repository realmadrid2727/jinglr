class Follow < ActiveRecord::Base
  include PublicActivity::Model
  
  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, polymorphic: true
  belongs_to :follower,   polymorphic: true
  
  tracked
  
  before_create  :check_permission
  after_create   :increment_counters, :add_notification
  after_destroy  :decrement_counters, :remove_notification
  
  def block!
    self.update_attribute(:blocked, true)
  end
  
  #############
  # Callbacks #
  #############
  # Don't allow people to follow themselves
  def check_permission
    if followable_type == "User"
      user = User.find(followable_id)
      follower = User.find(follower_id)
      
      errors.add(I18n::t('errors.follow.self_follow')) if user == follower
      errors.add(I18n::t('errors.follow.already_following')) if follower.follows?(user)
    end
  end
  
  # Increment the counters for the user and the follower
  # when someone starts following
  def increment_counters
    if followable_type == "User"
      user = User.find(followable_id)
      follower = User.find(follower_id)
      user.update_attribute(:followers_count_cache, user.followers_count)
      follower.update_attribute(:following_count_cache, follower.following_users_count)
    end
  end
  
  # Decrement the counters for hte user and the follower
  # when someone stops following
  def decrement_counters
    if followable_type == "User"
      user = User.find(followable_id)
      follower = User.find(follower_id)
      user.update_attribute(:followers_count_cache, user.followers_count)
      follower.update_attribute(:following_count_cache, follower.following_users_count)
    end
  end
  
  # Give the reciever a notification that they're being followed
  def add_notification
    if followable_type == "User"
      Notification.create(
        target_id: followable_id,
        target_type: "User",
        notice_id: id,
        notice_type: "Follow",
        user_id: followable_id,
        notifier_id: follower_id
      )
    end
  end
  
  # I'm wondering if removing notifications is a good idea
  # after a record is deleted. It's nice to have a record of
  # what happened in the past, but I'm going forward with it anyway
  def remove_notification
    if followable_type == "User"
      notice = Notification.where({
        target_id: followable_id,
        target_type: "User",
        notice_id: id,
        notice_type: "Follow",
        user_id: followable_id,
        notifier_id: follower_id
      }).first
      notice.blank? ? true : notice.destroy
    end
  end
end
