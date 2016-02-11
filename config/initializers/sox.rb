module Paperclip
  class Sox < Processor
    attr_accessor :file, :params, :format
    
    def initialize file, options = {}, attachment = nil
      super
      @file = file
      @params = options[:params]
      @current_format = File.extname(@file.path)
      @basename = File.basename(@file.path, @current_format)
      @format = options[:format]
      @instance = attachment.instance
    end

    def make
      src = @file
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      
      begin
        parameters = []
        parameters << @params
        parameters << ":source"
        parameters << ":dest"
        parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")
        success = Paperclip.run("sox", parameters, :source => "#{File.expand_path(src.path)}", :dest => File.expand_path(dst.path))
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error converting #{@basename} to mp3"
      end
      dst
      
    end
    
  end
end