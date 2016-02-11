class UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :check_for_username_existence, only: [:select_username, :set_username]
  
  helper_method :user_jingles, :current_user_details
  respond_to :html, :js, :json
  
  def index
    redirect_to home_path
  end
  
  def edit
    if params[:id].to_i == current_user.id
      
    else
      redirect_to edit_user_path(current_user) if params[:id].to_i == current_user.id
    end
  end
  
  def upload_avatar
    current_user.avatar = user_params[:avatar]
    respond_to do |format|
		  if current_user.save
        format.html {
          render json: [current_user.to_jq_upload].to_json,
          content_type: 'text/html',
          layout: false
        }
        format.json { render json: [current_user.to_jq_upload].to_json, status: :created, location: current_user }
      else
        format.html { render action: "new" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update_email
    respond_with(current_user, location: edit_user_path(current_user)) do |format|
      if current_user.update_attributes(email: user_params[:email])
        format.json { render json: {message: t('flash.notice.update', item: t('models.thing').downcase)}, status: :ok }
      else
        format.json { render json: {message: t('flash.alert.update', item: t('models.thing').downcase)}, status: :unprocessable_entity}
      end
    end
  end
  
  def update_password
    respond_with(current_user, location: edit_user_path(current_user)) do |format|
      if current_user.update_with_password(user_params)
        sign_in(current_user, :bypass => true)
        format.json { render json: {message: t('flash.notice.update', item: t('models.thing').downcase)}, status: :ok }
      else
        format.json { render json: {message: current_user.errors.full_messages.join(". ") + "."}, status: :unprocessable_entity}
      end
    end
  end
  
  def delete_avatar
    # ...
  end
  
  def jingles
    if params[:partial]
      render partial: "jingles/jingles", locals: {jingles: user_jingles}
    end
  end
  
  # New users from oauth need to select a username
  def select_username
    redirect_to home_path unless current_user.username.blank?
  end
  
  def set_username
    if current_user.update_attributes(username: params[:user][:username])
      redirect_to home_path, notice: t('flash.notice.set_username')
    else
      redirect_to select_username_user_path(current_user), alert: current_user.errors.full_messages.join(". ") + "."
    end
  end
  
protected
  def user_jingles
    @user_jingles ||= current_user.jingles.active.order("latest_at DESC").page(params[:page])
  end
  
  def current_user_details
    @current_user_details ||= current_user.detail
  end
  
private
  def user_params
    params.require(:user).permit(
      :username,
      :email,
      :password,
      :password_confirmation,
      :current_password,
      :avatar,
      :id,
      :provider,
      :uid,
      :name
    )
  end
end
