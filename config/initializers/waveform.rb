module Paperclip
  class Waveform < Processor
    def initialize file, options = {}, attachment = nil
      super

      @basename = File.basename(file.path)
      @waveform_opts = options[:convert_options]
      #@waveform_opts[:force] = true
      @instance = attachment.instance
    end

    def make
      wav = Tempfile.new [ @basename, '.wav']
      wav.binmode

      begin
        Paperclip.run("sox", ":source :dest", :source => "#{File.expand_path(file.path)}", :dest => File.expand_path(wav.path))
      rescue Cocaine::ExitStatusError => e
        raise Paperclip::Error, "error while processing wav for #{@basename}: #{e}"
      end

      png = Tempfile.new [ @basename, 'png' ]

      ::Waveform.generate wav, png, @waveform_opts
      
      # From solution in https://github.com/thoughtbot/paperclip/issues/671#issuecomment-21264860
      duration = `soxi -D #{File.expand_path(file.path)}`
      stat_data = `soxi #{File.expand_path(file.path)}`
      # TO FIX
      # Stat data with non-UTF-8 stuff won't save in the DB.
      #stat_data += `sox #{File.expand_path(file.path)} -n stat 2>&1`
      @instance.state = "complete"
      @instance.track_duration = duration
      @instance.original_track_duration = duration
      begin
        stat_data = stat_data.encode("UTF-8")
      rescue Encoding::UndefinedConversionError
        stat_data = "INVALID DATA"
      end
      
      @instance.stat = "Original:\n---------" + stat_data.force_encoding('UTF-8').squeeze(" ")
      
      png
    end
  end
end