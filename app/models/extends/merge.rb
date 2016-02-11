module Extends::Merge
  include Extends::Sox
  
  # Creating a jingle from merging existing jingles
  def create_from_origin(params)
    params[:tracks].each do |k,v|
      JingleOrigin.create(
        parent_id: id,
        # The "d" is added to params[:tracks] hash with duplicate IDs
        # so the hashes don't automatically merge
        jingle_id: k.gsub("d",""),
        offset: v
      )
    end
    
    combine_tracks_from_origin
    regenerate_waveform(false) # 'false' makes it generate as original
    
    if params[:desc] != ""
      activate(params[:desc])
      notify_original_creators
    end
  end
  
  def auto_merge_if_necessary
    if parent && parent.user_id == user_id
      parent.accept_merge!(self)
    end
  end
  
  # Accept a merge
  def accept_merge!(jingle)
    begin
      if merges_processed?
        unless merged_with?(jingle) # Prevent duplicate entries
          # Overwrite the current "latest.mp3" file with the newest
          rename_merge_file(jingle)
          delay.update_duration! # Update the duration of the track
          delay.regenerate_waveform # Generate the new waveform
          # TO DO regenerate waveform here
          create_merge_notification!(jingle, "JingleAccept") unless user_id == jingle.user_id
          view_merge_request_notification!(jingle)
          # Set the merge object to merged
          child_merges.where({
            child_jingle_id: jingle.id
          })[0].update_attribute(:state, JingleMerge::MERGE_STATE['merge'])
          update_jingle_tracks_count!
          update_attribute(:latest_at, Time.now)
        end
      else
        raise "All merges not processed yet"
      end
    #rescue
    #  return false
    end
  end
  
  def decline_merge!(jingle, reason)
    create_merge_notification!(jingle, "JingleDecline") unless user_id == jingle.user_id
    view_merge_request_notification!(jingle)
    # Remove the merge object
    child_merges.where({
      child_jingle_id: jingle.id
    })[0].update_attributes(state: JingleMerge::MERGE_STATE['decline'], reason: reason)
    delete_merge_file(jingle)
    jingle.update_attribute(:parent_id, nil)
  end
  
  
  def create_merge_association!
    JingleMerge.create(
      child_jingle_id: id,
      parent_jingle_id: parent.id,
      child_type: "original",
      parent_type: "latest",
      child_offset: child_offset,
      parent_offset: parent_offset
    )
  end
end