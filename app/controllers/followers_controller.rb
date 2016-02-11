class FollowersController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html, :js, :json
  
  def followers
    
  end
  
  def following
    
  end
  
  def toggle
    user = User.where({username: params[:username]})[0]
    
    unless current_user.follows?(user)
      respond_with(user, location: profile_path(user.username)) do |format|
        if current_user.follow(user)
          format.js { render text: user.followers_count, status: :ok }
        else
          format.js { render text: t('flash.alert.follow', item: user.display_name).to_json, status: :unprocessable_entity}
        end
      end
    else
      respond_with(user) do |format|
        if current_user.stop_following(user)
          format.js { render text: user.followers_count, status: :ok }
        else
          format.js { render text: t('flash.alert.follow', item: user.display_name).to_json, status: :unprocessable_entity}
        end
      end
    end
  end
  
  def create
    user = User.where({username: params[:username]})[0]
    
    respond_with(user, location: profile_path(user.username)) do |format|
      if current_user.follow(user)
        format.js { render text: user.followers_count, status: :ok }
      else
        format.js { render text: t('flash.alert.follow', item: user.display_name).to_json, status: :unprocessable_entity}
      end
    end
  end
  
  def destroy
    user = User.where({username: params[:username]})[0]
    
    respond_with(user) do |format|
      if current_user.stop_following(user)
        format.js { render text: user.followers_count, status: :ok }
      else
        format.js { render text: t('flash.alert.follow', item: user.display_name).to_json, status: :unprocessable_entity}
      end
    end
  end
  
private
  #def follow_params
  #  params.permit(:user_id, :follower_id)
  #end
end
