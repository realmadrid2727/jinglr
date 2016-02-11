class SiteController < ApplicationController
  #before_filter :authenticate_user!, only: [:index]
  skip_before_filter :authenticate_user!
  respond_to :html, :js, :json
  layout 'landing'
  
  include ApplicationHelper
  
  def index
    if user_signed_in?
      redirect_to home_path
    else
      
    end
  end
  
  def help
    render layout: "application"
  end
  
  def privacy
    render layout: "application"
  end
  
  def leave_feedback
    render_modal(t('site.leave_feedback.title'), "site/leave_feedback_form", leave_feedback_create_path)
  end
  
  def leave_feedback_create
    @feedback = SiteFeedback.new
    @feedback.user_id = current_user.id
    @feedback.desc = site_params[:desc]
    @feedback.site_feedback_category_id = site_params[:category_id]
    respond_with(@feedback, location: home_path) do |format|
      if @feedback.save
        format.json { render json: {message: t('flash.notice.feedback')}, status: :ok }
      else
        format.json { render text: format_errors_for_js(@feedback.errors.full_messages), status: :unprocessable_entity }
      end
    end
  end

  
  def error_404
    render layout: 'error', status: 404
  end
  
  def login_or_register
    render_modal(t('site.login_or_register.title'), "site/login_or_register", login_or_register_path, {ignore_footer: true})
  end
  
private
  def site_params
    params.permit(:id, :desc, :user_id, :category_id)
  end
end
