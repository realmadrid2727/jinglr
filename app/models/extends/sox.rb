module Extends::Sox
  extend ActiveSupport::Concern
  
  def combine_tracks
    begin
      tracks = ""
      array = normalized_offsets
      #array.each {|a| a.mark_processing!}
      # If any of the tracks don't exist yet, raise an error
      # so the delayed_job worker will try to process the file
      # again until the file exists.
      
      array.each_with_index do |jingle, i|
        unless File.exist?(jingle.track.path)
          sox_logger.info("#{jingle.track.path} does not exist.")
          raise Errno::ENOENT, "#{jingle.track.path} not processed yet"
        end
        Rails.logger.debug("JINGLE: #{jingle.id} - #{jingle.offset}")
        sox_logger.info("Added track: #{jingle.track.path}")
        if jingle.offset > 0
          tracks += (" -v 0.8 " + jingle.track.path + " -p pad " + jingle.offset.to_s + " 0 | sox - -m")
        elsif jingle.offset == 0
          if i+1 == array.length
            tracks += (" -v 0.8 " + jingle.track.path)
          else
            tracks += (" -v 0.8 " + jingle.track.path + " -p pad " + jingle.offset.to_s + " 0 | sox - -m")
          end
          # Add the pipe trail unless it's the last element in the array
          tracks += " | sox - -m" unless jingle.offset == 0 #[i+1].nil?
        end
      end
      
      output = parent.assets_path
      command = "sox #{tracks} #{output}merge-#{parent.id}-#{id}.mp3"
      #return "COMMAND: "+command
      #Rails.logger.debug(command)
      result = `#{command}`
      # TO FIX
      # Stat data with non-UTF-8 stuff won't save in the DB.
      #stat_data = `sox #{output}merge-#{parent.id}-#{id}.mp3 -n stat`
      #stat_data = stat_data.encode("UTF-8")
      stat_data = `soxi #{output}merge-#{parent.id}-#{id}.mp3`
      update_attribute(:stat, self.stat + "\n\n" + stat_data)
      parent.child_merges.each {|m| m.update_attribute(:merged_at, Time.now) if m.merged_at.blank?}
      array.each {|a| a.mark_completed!}
    rescue => error
      sox_logger.debug("Encountered error:\n")
      sox_logger.debug($!.backtrace)
      #return $!.backtrace
      return false
    end
  end

  # Create an array of tracks with their offsets
  def normalized_offsets
    array = []
    
    if parent
      merges_array = parent.
        child_merges.
        sort_by(&:created_at)
        
      merges_array.each_with_index do |m, i|
        # Setting up the first values  
  
        if m.child_offset > 0
          m.child_jingle.offset = m.child_offset
          
          m.child_jingle.absolute_offset = m.child_offset
            
          array << m.child_jingle
          if i > 0
            array.each do |a|
              array.each_with_index do |x,y|
                if a.id == m.child_jingle.id && a.absolute_offset > x.absolute_offset
                  #Rails.logger.debug("#{a.id} vs. #{m.child_jingle.id} OFFSETS: #{a.absolute_offset} > #{x.absolute_offset}")
                  array.insert(y-1, array.delete_at(-1))
                  break
                end
                
                if a.id == m.child_jingle.id && a.absolute_offset < x.absolute_offset
                  #Rails.logger.debug("#{a.id} vs. #{m.child_jingle.id} OFFSETS: #{a.absolute_offset} < #{x.absolute_offset}")
                  array.insert(y+1, array.delete_at(-1))
                  break
                end
              end
            end
          end
        else
          m.child_jingle.offset = 0
          array.unshift(m.child_jingle)
        end
        
        # Sets up the first merge
        if i == 0
          # If the first merge has a parent offset
          if m.parent_offset > 0
            m.parent_jingle.offset = m.parent_offset
            m.parent_jingle.absolute_offset = m.parent_offset
            array << m.parent_jingle
          else
            m.parent_jingle.offset = 0
            m.parent_jingle.absolute_offset = 0
            array.unshift(m.parent_jingle)
          end
        end
        
        if m.parent_offset > 0
          array[1].offset = m.parent_offset
          array.each_with_index do |a,n|
            a.absolute_offset = 0 if a.absolute_offset.nil?
            unless n == 0
              a.absolute_offset += m.parent_offset unless a.id == m.child_jingle.id
            end
          end
        end
      end
    end
    
    array = array.reverse
    
    array.each_with_index do |a,n|
      unless a.offset == 0 # Skip the first track
        Rails.logger.debug("MATH: #{a.id} - #{array[n+1].absolute_offset}")
        a.absolute_offset = 0 if a.absolute_offset.blank? # In case of a nil
        array[n+1].absolute_offset = 0 if array[n+1].absolute_offset.blank? # In case of a nil
        a.offset = (a.absolute_offset - array[n+1].absolute_offset).abs
      end
    end
    #array.each {|a| Rails.logger.debug("OFFSET: ID#{a.id} #{a.offset}")}
    return array
  end
  
  
  # Asbolutes
  # 594 = 0.0
  # 595 = 2.0
  #M584 = 3.0
  # 585 = 9.0
  
  # For absolute:
  # The shift on child offsets only happens to the FIRST element on the right side. Ex. [a,Bx,C,d]
  # The shift on parent offsets adds the offset to EVERYTHING on the right
  
  # For relative:
  # Child offsets shift FIRST element on the right with formula
  # Parent offsets shift SECOND element in array
  
  # CHILD   M584 (0) -> 585 (6)
  # PARENT  594 (0) -> M584 (3) -> 585 (6)
  #                  Shift all +3
  # CHILD   594 (0) -> 595 (2) -> M584 (1) -> 585 (6)
  #     <- sub absolute L from R to get relative R ->
  #                    9 = last + (last-1) + (last-2)
  
  
  
  def combine_tracks_from_origin
    begin
      tracks = ""
      offsets = []
      # This is disgusting, but I want to get this concept working
      # and my brain isn't cooperating. I'm trying to account for
      # any tracks that both have offsets by subtracting the lower offset
      # from the higher one, and reassigning the higher one with the new value
      # and setting the lower one to 0. That way there are no pauses before the track begins
      os = origins.sort_by(&:offset).reverse
      os.each {|o| offsets << o.offset}
      os.first.offset = offsets[0] - offsets[1]
      os.last.offset = 0
      os.each do |o|
        unless File.exist?(o.jingle.latest_path)
          sox_logger.info("#{o.jingle.latest_path} does not exist.")
          raise Errno::ENOENT, "#{o.jingle.latest_path} not processed yet"
        end
        sox_logger.info("Added track: #{o.jingle.latest_path}")
        if o.offset > 0
          tracks += (" -v 0.8 " + o.jingle.latest_path + " -p pad " + o.offset.to_s + " 0 | sox - -m")
        elsif o.offset == 0
          #tracks += (" -v 1 " + o.jingle.latest_path + " pad " + o.offset.to_s + " 0 | sox - -m")
          tracks += (" -v 0.8 " + o.jingle.latest_path)
        end
      end
      output = assets_path
      #tracks = tracks[0..-11] # Remove the trailing command
      puts "sox #{tracks} #{output}original.mp3"
      m = os.first.offset == 0 ? "-m " : ""
      result = `sox #{m}#{tracks} #{output}original.mp3`
      duration = `soxi -D #{output}original.mp3`
      stat_data = `soxi #{output}original.mp3`
      # TO FIX
      # Stat data with non-UTF-8 stuff won't save in the DB.
      #stat_data = `sox #{output}original.mp3 -n stat`
      update_attributes(
        track_duration: duration,
        state: "complete",
        track_file_name: "origin.mp3",
        track_content_type: "audio/mpeg",
        track_file_size: (File.size("#{output}original.mp3") rescue 0),
        stat: stat_data #.encode("UTF-8").force_encoding('UTF-8')
      )
    rescue => error
      sox_logger.debug("Encountered error:\n")
      sox_logger.debug($!.backtrace)
      return false
    end
  end
  
  def update_duration!
    unless track.blank?
      duration = `soxi -D #{latest_path}`
      update_attribute(:track_duration, duration)
    end
  end
  
  def update_original_duration!
    unless track.blank?
      duration = `soxi -D #{track.path}`
      update_attribute(:original_track_duration, duration)
    end
  end
  
  def sox_logger
    @@sox_logger ||= Logger.new("#{Rails.root}/log/sox.log")
  end
end

=begin
  Multi-track
  
  COMMAND: sox drums.mp3 -p pad 2 0 | sox - -m bass.mp3 -p pad 2 0 | sox - -m synth.mp3 combined.mp3
  
  It runs backwards
  synth.mp3 plays from 0:00
  bass.mp3 plays from 0:02
  drums.mp3 plays from 0:04
=end