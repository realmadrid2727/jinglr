class JingleLikesController < ApplicationController
  before_filter :authenticate_user!
  
  helper_method :jingle
  respond_to :html, :js, :json
  
  def toggle
    unless jingle.liked_by?(current_user)
      @like = JingleLike.new(jingle_id: params[:jingle_id], user_id: current_user.id)
      
      respond_with(@like, location: jingle_path(jingle)) do |format|
        if @like.save
          # Have to increment the counter manually, because it's
          # updated after create, so we receive out-of-date data here
          format.js { render text: jingle.jingle_likes_count + 1, status: :created }
        else
          format.js { render nothing: true, status: :unprocessable_entity}
        end
      end
    else
      @like = current_user.like(jingle)
      respond_with(@like) do |format|
        if @like.destroy
          format.js { render text: jingle.jingle_likes_count - 1, status: :ok }
        else
          format.js { render nothing: true, status: :unprocessable_entity}
        end
      end
    end
  end
  
  def create
    unless jingle.liked_by?(current_user)
      @like = JingleLike.new(jingle_id: params[:jingle_id], user_id: current_user.id)
      
      respond_with(@like, location: jingle_path(jingle)) do |format|
        if @like.save
          format.js { render text: jingle.jingle_likes_count + 1, status: :created }
        else
          format.js { render nothing: true, status: :unprocessable_entity}
        end
      end
    end
  end
  
  def destroy
    @like = JingleLike.find(params[:id])
    
    respond_with(@like) do |format|
      if @like.destroy
        format.js { render text: jingle.jingle_likes_count - 1, status: :ok }
      else
        format.js { render nothing: true, status: :unprocessable_entity}
      end
    end
  end
  
protected
  def jingle
    @jingle ||= Jingle.find(params[:jingle_id])
  end
  
private
  def jingle_like_params
    params.permit(:user_id, :jingle_id)
  end
end
