class MixerController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json
  helper_method :jingle
  
  def index
    #@jingles = Jingle.where({id: current_user.detail.track_mixer_list_array})
    # Can't use the nice 'where' AR method because if the user selects the same track twice,
    # it will only return one
    @jingles = []
    current_user.detail.track_mixer_list_array.each do |track|
      @jingles << Jingle.find(track)
    end
  end
  
  def show
    
  end
  
  def get_track
    render partial: "mixer/browser_track", locals: {jingle: jingle}
  end
  
  def add_track
    if current_user.add_track_to_mixer!(jingle)
      get_track
    else
      render text: t('track_mixer.errors.too_many_tracks'), status: :unprocessable_entity
    end
  end
  
  def remove_track
    if current_user.remove_track_from_mixer!(jingle)
      render nothing: true, status: :ok
    else
      render text: t('track_mixer.errors.remove_error'), status: :unprocessable_entity
    end
  end
  
protected
  def jingle
    @jingle ||= Jingle.find(params[:jingle_id])
  end
end
