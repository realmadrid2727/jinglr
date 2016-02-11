class SearchController < ApplicationController
  include Extends::Normalizer
  include ActionView::Helpers::TextHelper
  
  def show
    if params[:sort]
      start_at = Time.now - 1.month
      end_at   = Time.now
      start_at = normalize_sort_time(params[:from]) if params[:from]
      end_at = normalize_sort_time(params[:to]) if params[:to]
      
      if params[:sort] == "favorites"
        @jingles ||= Kaminari.paginate_array(Jingle.tag_most_favorites(params[:q], start_at, end_at)).page(params[:page])
      elsif params[:sort] == "likes"
        @jingles ||= Kaminari.paginate_array(Jingle.tag_most_likes(params[:q], start_at, end_at)).page(params[:page])
      end
    else
      @jingles ||= Jingle.tagged_with(params[:q]).active.newest.page(params[:page])
    end
    
    @hashtags = Jingle.latest_tags
    
    if params[:partial]
      render partial: "jingles/jingles", locals: {jingles: @jingles, search: true,
        search_title: t('search.index.results', count: pluralize(@jingles.length, t('search.index.labels.result'))),
        search_term: params[:q], bypass_header: params[:page] ? true : false}
    end
  end
  
end
