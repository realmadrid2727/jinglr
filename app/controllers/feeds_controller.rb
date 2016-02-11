class FeedsController < ApplicationController
  before_filter :authenticate_user!
  include Extends::Normalizer
  helper_method :jingles
  respond_to :html, :js, :json
  
  def index
    @hashtags = Jingle.latest_tags
    if params[:partial]
      render partial: "jingles/jingles", locals: {jingles: jingles, bypass_header: params[:page] ? true : false}
    end
  end

protected
  def jingles
    ids = current_user.follows_scoped.collect {|f| f.followable_id}
    
    if params[:sort]
      start_at = Time.now - 1.month
      end_at   = Time.now
      start_at = normalize_sort_time(params[:from]) if params[:from]
      end_at = normalize_sort_time(params[:to]) if params[:to]
      
      if params[:sort] == "favorites"
        @jingles ||= Jingle.most_favorites(start_at, end_at).where(user_id: ids).page(params[:page])
      elsif params[:sort] == "likes"
        @jingles ||= Jingle.most_likes(start_at, end_at).where(user_id: ids).page(params[:page])
      end
    else
      @jingles ||= Jingle.active.newest.where(user_id: ids).page(params[:page])
    end
  end
end
