class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  
  include ApplicationHelper
  helper_method :notifications
  respond_to :html, :js, :json
  
  def index
    #Notification.view_set!(current_user.notifications)
    if params[:partial]
      render partial: "notifications", locals: {notifications: notifications}
    end
  end
  
  def mark_viewed
    notification = Notification.find(params[:id])
    
    if can_edit?(notification)
      unless notification.viewed?
        notification.view!
      else
        notification.unview!
      end
    end
    
    render json: {viewed: notification.viewed?} 
  end
  
  def mark_all_viewed
    Notification.view_set!(current_user.notifications)
    render nothing: true
  end
  
  def update_settings
    respond_with(current_user, location: notifications_user_index_path) do |format|
      if current_user.notification_setting.update_all(params[:notification_settings])
        format.js { render text: t('flash.notice.update', item: t('models.thing').downcase).to_json, status: :ok }
      else
        format.js { render text: t('flash.alert.update', item: t('models.thing').downcase).to_json, status: :unprocessable_entity}
      end
    end
  end
  
  # Header notifications
  def remote
    render partial: "notifications/header_notifications"
  end
  
  def remote_notification
    render partial: "notifications/header_notification", locals: {notification: Notification.find(params[:id])}
  end

protected
  def notifications
    @notifications ||= current_user.notifications.order("created_at DESC").page(params[:page])
  end

private
  def notification_setting_params
    params.require(:notification_settings).permit(
      :email_jingle_likes,
      :email_jingle_comments,
      :email_jingle_merge,
      :email_jingle_accept,
      :email_jingle_decline,
      :email_jingle_origin,
      :email_jingle_update
    )
  end
end
