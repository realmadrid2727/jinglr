require "fileutils"

module Extends::JinglePath
  # Path to waveform image
  def waveform_path(latest = true)
    file = assets_path + (latest ? latest_waveform_basename : waveform_basename)
  end
  
  def waveform_url(latest = true)
    file = assets_url + (latest ? latest_waveform_basename : waveform_basename) + "?#{Time.now.to_i}"
    if File.exist?(waveform_path(latest))
      return file
    else
      if File.exist?(waveform_path(false))
        return waveform_url(false)
      else
        return false
      end
    end
  end
  
  # Path to pending merged tracks (pending merges)
  def merge_path(jingle)
    file = assets_path + merge_basename(jingle)
  end
  
  def merge_url(jingle, force = false)
    file = assets_url + merge_basename(jingle) + "?#{Time.now.to_i}"
    if File.exist?(merge_path(jingle))
      return file
    else
      if force
        return file
      else
        return false
      end
    end
  end
  
  # Path to latest track (AKA merged tracks)
  def latest_path(force = false)
    file = assets_path + latest_basename
    if File.exist?(file)
      return file
    else
      if force
        return file
      else
        return track.path
      end
    end
  end
  
  def latest_url(force = false)
    file = assets_url + latest_basename + "?#{Time.now.to_i}"
    if latest_path != track.path && File.exist?(latest_path)
      return file
    else
      track.url
      #if force
      #  return file
      #else
      #  return false
      #end
    end
  end
  
  
  # Basenames
  def latest_basename
    "latest.mp3"
  end
  
  def merge_basename(jingle)
    "merge-#{id}-#{jingle.id}.mp3"
  end
  
  def waveform_basename
    "waveform.png"
  end
  
  def latest_waveform_basename
    "latest_waveform.png"
  end
  
  # Path to assets for the jingle
  def assets_path
    unless track.blank?
      File.dirname(track.path) + "/"
    else
      dir = "#{Rails.root}/public/assets/jingles/#{id}/tracks"
      begin
        FileUtils.mkdir_p dir
      rescue Errno::EEXIST
        return dir + "/"
      end
      return dir + "/"
    end
  end
  
  def assets_url
    File.dirname(track.url) + "/"
  end
end