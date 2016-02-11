class UserDetail < ActiveRecord::Base
  include PublicActivity::Model
  
  belongs_to :user
  
  tracked
  
  def add_track_to_mixer!(jingle)
    if can_add_track_to_mixer?
      ids = track_mixer_list.nil? ? [] : track_mixer_list.split(",")
      ids << (jingle.id)
      update_attribute(:track_mixer_list, ids.join(","))
    else
      return false
    end
  end
  
  def remove_track_from_mixer!(jingle)
    if track_mixer_list.nil?
      return true
    else
      ids = track_mixer_list.split(",").delete_if { |i| i.to_i == jingle.id }.join(",")
      update_attribute(:track_mixer_list, ids)
    end
  end
  
  def can_add_track_to_mixer?
    if track_mixer_list.nil?
      return true
    else
      if track_mixer_list_array.length > 1
        return false
      else
        return true
      end
    end
  end
  
  def track_mixer_list_array
    return [] if track_mixer_list.nil?
    track_mixer_list.split(",").map {|i| i.to_i}
  end
  
  def track_mixer_too_many_tracks?
    track_mixer_list_array.length >= APP_CONFIG["track_mixer_max"].to_i
  end
end
