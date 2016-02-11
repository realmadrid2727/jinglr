module Extends::Waveform
  extend ActiveSupport::Concern
  
  def regenerate_waveform(latest = true)
    mark_processing! # Set state to processing
    basename = latest_path
    wav = Tempfile.new [ basename, '.wav'] # Create a WAV tempfile to generate the waveform from
    wav.binmode
    
    # Run the processing to get the WAV made
    begin
      Paperclip.run("sox", ":source :dest", source: "#{File.expand_path(latest_path)}", dest: File.expand_path(wav.path))
    rescue Cocaine::ExitStatusError => e
      raise Paperclip::Error, "error while processing wav for #{basename}: #{e}"
    end
    
    png = waveform_path(latest)
    
    # Generate the waveform image
    ::Waveform.generate wav, png, Jingle::WAVEFORM_OPTS
    
    mark_completed! # Mark as completed
    
    wav.close
    wav.unlink
  end
end