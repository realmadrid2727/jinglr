class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActionController::RoutingError, with: :render_404
  
  before_filter :configure_devise_params, if: :devise_controller?
  before_filter :check_for_username_existence
  
  def configure_devise_params
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:username, :email, :password, :password_confirmation)
    end
    
    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:username, :password)
    end
  end
  
  # 
  def check_for_username_existence
    if user_signed_in?
      if current_user.username.blank?
        redirect_to select_username_user_path(current_user)
      end
    end
    return true
  end
 
  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end
  
  # Render 404
  def render_404
    #raise ActionController::RoutingError.new('Not Found')
    #render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    redirect_to error_404_path
  end
end
