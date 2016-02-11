module Extends::FollowJingle
  def follow_jingle
    user.follow(jingle) unless user == jingle.user
  end
  
  def unfollow_jingle
    user.stop_following(jingle) unless user == jingle.user
  end
end