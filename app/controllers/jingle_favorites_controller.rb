class JingleFavoritesController < ApplicationController
  before_filter :authenticate_user!
  
  helper_method :jingle
  respond_to :html, :js, :json
  
  def index
    @favorites = current_user.favorites.order("created_at DESC").page(params[:page])
    if params[:partial]
      render partial: "jingles/jingles", locals: {jingles: @favorites}
    end
  end
  
  # TO DO
  # When toggling like, make sure to update the favorite count in the view
  def toggle
    unless jingle.favorited_by?(current_user)
      @favorite = JingleFavorite.new(jingle_id: params[:jingle_id], user_id: current_user.id)
      
      respond_with(@favorite, location: jingle_path(jingle)) do |format|
        if @favorite.save
          format.js { render nothing: true, status: :created }
        else
          format.js { render nothing: true, status: :unprocessable_entity}
        end
      end
    else
      @favorite = current_user.favorite(jingle)
      respond_with(@favorite) do |format|
        if @favorite.destroy
          format.js { render nothing: true, status: :ok }
        else
          format.js { render nothing: true, status: :unprocessable_entity}
        end
      end
    end
  end
  
  def create
    unless jingle.liked_by?(current_user)
      @favorite = JingleFavorite.new(jingle_id: params[:jingle_id], user_id: current_user.id)
      
      respond_with(@favorite, location: jingle_path(jingle)) do |format|
        if @favorite.save
          format.js { render nothing: true, status: :created }
        else
          format.js { render nothing: true, status: :unprocessable_entity}
        end
      end
    end
  end
  
  def destroy
    @favorite = JingleFavorite.find(params[:id])
    
    respond_with(@favorite) do |format|
      if @favorite.destroy
        format.js { render nothing: true, status: :ok }
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
  def jingle_favorite_params
    params.permit(:user_id, :jingle_id)
  end
end
