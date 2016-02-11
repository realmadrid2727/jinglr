class JingleFavorite < ActiveRecord::Base
  include Extends::FollowJingle
  include PublicActivity::Model
  
  belongs_to :jingle
  belongs_to :user
  
  tracked owner: ->(controller, model) { model && model.user },
          recipient: ->(controller, model) { model && model.jingle.user }
  
  after_create  :increment_jingle_favorites_count, :follow_jingle
  before_destroy :decrement_jingle_favorites_count, :unfollow_jingle
  
  def increment_jingle_favorites_count
    jingle.update_attribute(:jingle_favorites_count, jingle.jingle_favorites_count + 1)
  end
  
  def decrement_jingle_favorites_count
    jingle.update_attribute(:jingle_favorites_count, jingle.jingle_favorites_count - 1)
  end
end
