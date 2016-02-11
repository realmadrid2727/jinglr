# UNUSED, IT SEEMS
=begin
module Paperclip
  class Waveform < Processor
    def initialize file, options = {}, attachment = nil
      super

      @basename = File.basename(file.path)
      @waveform_opts = options[:convert_options]
      @waveform_opts[:force] = true
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
      Rails.logger.debug("MARKING COMPLETED FROM WAVEFORM PROCESSOR")
      @instance.mark_completed!
      
      png
    end
  end
end
=end