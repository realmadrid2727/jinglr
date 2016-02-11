class ProfilesController < ApplicationController
  helper_method :user, :jingles, :user_followers, :user_following
  
  def show
    if params[:partial]
      render partial: "jingles/jingles", locals: {jingles: jingles}
    end
  end
  
  def followers
    if params[:partial]
      render partial: "followers", locals: {followers: user_followers}
    end
  end
  
  def following
    if params[:partial]
      render partial: "followers", locals: {followers: user_following}
    end
  end
  
protected
  def user
    begin
      @user ||= User.where({username: params[:username]})[0]
      routing_error if @user.nil?
      return @user
    rescue NoMethodError
      routing_error
    end
  end
  
  def jingles
    @jingles ||= user.jingles.active.order("latest_at DESC").page(params[:page])
  end
  
  def user_followers
    @user_followers ||= user.followers_scoped.where("followable_type = 'User'").order("created_at DESC").page(params[:page])
  end
  
  def user_following
    @user_following ||= user.follows_scoped.where("followable_type = 'User'").order("created_at DESC").page(params[:page])
  end
end
