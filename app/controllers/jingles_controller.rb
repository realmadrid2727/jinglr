class JinglesController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :connections]
  include ApplicationHelper
  include Extends::Normalizer
  helper_method :jingle, :jingles
  respond_to :html, :js, :json
  
  #########
  # Pages #
  #########
  def index
    @hashtags = Jingle.latest_tags
    if params[:partial]
      render partial: "jingles/jingles", locals: {jingles: jingles, bypass_header: params[:page] ? true : false}
    end
  end
  
  def show
    
  end
  
  def new
    @new_jingle = Jingle.new
    
    if params[:option] == 'remote'
      render_modal(t('jingles.new.title'), "jingles/form", new_jingle_path)
    end
  end
  
  def edit
  
  end
  
  
  ########
  # CRUD #
  ########
  def create
    @new_jingle = current_user.jingles.create(jingle_params)
    
    respond_to do |format|
		  if @new_jingle.save
        format.html {
          render json: [@new_jingle.to_jq_upload].to_json,
          content_type: 'text/html',
          layout: false
        }
        format.json { render json: [@new_jingle.to_jq_upload].to_json, status: :created, location: @new_jingle }
      else
        #@file.errors[:partial_refresh_url] = files_upload_product_path(@file.product_id)
        errors = t('flash.alert.jingle_upload') #format_errors_for_js(@new_jingle.errors.full_messages)
        format.html { render action: "new" }
        format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
  
  end
  
  def destroy
    jingle_id = jingle.id
    respond_to do |format|
      if can_edit?(jingle) && jingle.destroy
        format.html { redirect_to jingles_path, notice: t('flash.notice.destroy', item: t('models.jingle'))}
        format.js {}
        format.json { render json: {jingle_id: jingle_id} }
      else
        format.html { redirect_to jingle_path(jingle), alert: t('flash.notice.destroy', item: t('models.jingle'))}
        format.js { render text: t('flash.alert.destroy', item: t('models.jingle')), status: :unprocessable_entity }
      end
    end
  end
  
  def add
    if jingle_params[:tracks]
      params[:jingle][:tracks].each do |k,v|
        if k.to_i == jingle.parent.id
          jingle.parent_offset = v
        elsif k.to_i == jingle.id
          jingle.child_offset = v
        end
      end
      
    end
    
    # Add desc and activate
    current_user.tag(jingle, with: extract_hashtags(params[:jingle][:desc]), on: :hashtags)
    redirect_path = jingle.has_parent? ? open_jingle_path(jingle.parent, open: "tracks") : jingles_user_index_path
    
    respond_to do |format|
      if can_edit?(jingle) && jingle.activate(params[:jingle][:desc]) #jingle.can_merge_track?(params[:force])
        format.html { redirect_to redirect_path, notice: t("flash.notice.create", item: jingle.class)}
        format.js {}
      else
        format.html { redirect_to new_jingle_path }
        format.js {}
      end
    end
    
    rescue NoMethodError
      nice_try
  end
  
  # Track mixer merge to create new track
  def merge
    # Add desc and activate
    @new_jingle = current_user.jingles.create
    current_user.tag(@new_jingle, with: extract_hashtags(params[:jingle][:desc]), on: :hashtags)
    redirect_path = jingles_user_index_path #jingle.has_parent? ? open_jingle_path(jingle.parent, open: "tracks") : jingles_user_index_path
    
    respond_to do |format|
      if @new_jingle.delay.create_from_origin(params[:jingle]) #jingle.can_merge_track?(params[:force])
        format.html { redirect_to redirect_path, notice: t("flash.notice.create", item: @new_jingle.class)}
        format.js {}
      else
        format.html { render action: "new" }
        format.js {}
      end
    end
  end
  
  def toggle_follow
    unless current_user.following?(jingle)
      respond_with(jingle, location: jingle_path(jingle)) do |format|
        if current_user.follow(jingle)
          format.js { render text: t('flash.notice.follow_jingle'), status: :created }
          format.json { render json: {jingle_id: jingle.id, message: t('flash.notice.follow_jingle')} }
        else
          format.js { render nothing: true, status: :unprocessable_entity }
        end
      end
    else
      respond_with(jingle) do |format|
        if current_user.stop_following(jingle)
          format.js { render text: t('flash.notice.unfollow_jingle'), status: :ok }
          format.json { render json: {jingle_id: jingle.id, message: t('flash.notice.unfollow_jingle')} }
        else
          format.js { render nothing: true, status: :unprocessable_entity }
        end
      end
    end
  end  
  
  ##########
  # Remote #
  ##########
  
  def merge_remote
    render partial: "jingles/mixing_mode", locals: {jingle: jingle}
  end
  
  def add_track_remote
    if jingle.complete?
      render partial: "mixer/track", locals: {jingle: jingle, i: 1}
    else
      render partial: "mixer/track_processing", locals: {jingle: jingle}
    end
  end
  
  # Checks the status of the jingle, to see whether it has been merged or not
  def check_status
    #processing = current_user.jingles.processing
    #parent_state = jingle.has_parent?
    if jingle.merges_processed?(!jingle.has_parent?) && jingle.active?
      render status: :created, text: jingles_user_index_path #, notice: t('flash.notice.create', item: t('models.jingle'))
    else
      render text: "Processing..."
    end
  end
  
  # Checks the status of the jingle, to see whether it has generated so it can go in the add track mixer
  def check_track_status
    #processing = current_user.jingles.processing
    if jingle.complete?
      render status: :created
    else
      render status: 102
    end
  end
  
  # Connections
  def connections
    render partial: "jingles/connections", locals: {jingle: jingle}
  end
  
  
  ##################
  # Merging tracks #
  ##################
  def accept
    respond_to do |format|
      if can_edit?(jingle.parent) && jingle.parent.accept_merge!(jingle)
        format.html { redirect_to open_jingle_path(jingle.parent, open: "tracks"), notice: t('flash.notice.accept_merge') }
        format.js { render status: :created }
        format.json { render json: {jingle_id: jingle.id, message: t('flash.notice.accept_merge')} }
      else
        format.html { redirect_to open_jingle_path(jingle.parent, open: "tracks"), alert: t('flash.alert.accept_merge') }
        format.js { render status: :unprocessable_entity }
        format.json { render json: {jingle_id: jingle.id, message: t('flash.alert.accept_merge')} }
      end
    end
  end
  
  def confirm_decline_merge
    render_modal(t('jingles.tracks.decline.title'), "jingle_comments/track_decline_comment_form", decline_merge_jingle_path(jingle))
  end
  
  def decline
    parent = jingle.parent
    respond_to do |format|
      if can_edit?(jingle.parent) && jingle.parent.decline_merge!(jingle, params[:reason])
        format.html { redirect_to open_jingle_path(parent, open: "tracks"), notice: t('flash.notice.decline_merge') }
        format.js { render text: "#{t('flash.notice.decline_merge')}", status: :ok }
      else
        format.html { redirect_to open_jingle_path(jingle.parent, open: "tracks"), alert: t('flash.alert.decline_merge') }
        format.js { render text: t('flash.alert.decline_merge'), status: :unprocessable_entity }
      end
    end
  end
  
protected

  def jingle
    begin
      if params[:option] == 'remote'
        @jingle = nil
      else
        @jingle ||= Jingle.find((params[:id] || params[:jingle][:parent_id]))
      end
    rescue ActiveRecord::RecordNotFound
      routing_error
    end
  end
  
  def jingles
    if params[:sort]
      start_at = Time.now - 1.month
      end_at   = Time.now
      start_at = normalize_sort_time(params[:from]) if params[:from]
      end_at = normalize_sort_time(params[:to]) if params[:to]
      
      if params[:sort] == "favorites"
        @jingles ||= Jingle.most_favorites(start_at, end_at).page(params[:page])
      elsif params[:sort] == "likes"
        @jingles ||= Jingle.most_likes(start_at, end_at).page(params[:page])
      end
    else
      @jingles ||= Jingle.active.newest.page(params[:page])
    end
  end
  
private
  
  # If they try something slick, like forcing their way through disabled buttons to submit a form
  def nice_try
    redirect_to jingles_path, alert: t('flash.alert.nice_try')
  end
  
  def jingle_params
    params.require(:jingle).permit(
      :user_id,
      :parent_id,
      :desc,
      :track_file_name,
      :track_content_type,
      :track_file_size,
      :track_updated_at,
      :track,
      :force_create,
      :child_offset,
      :parent_offset,
      :tracks => {}
    )
  end
end
