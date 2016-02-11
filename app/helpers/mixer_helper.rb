module MixerHelper
  def track_mixer_has_tracks?
    current_user.detail.track_mixer_list_array.length > 1
  end
  
  def track_mixer_has_track?
    current_user.detail.track_mixer_list_array.length > 0
  end

end
