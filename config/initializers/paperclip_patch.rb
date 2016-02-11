=begin
module Paperclip
  class Attachment
    # I need access to the AR instance in order to scope things by the site.
    def post_process_styles
      log("Post-processing #{name}")
      @styles.each do |name, args|
        begin
          raise RuntimeError.new("Style #{name} has no processors defined.") if args[:processors].blank?
          @queued_for_write[name] = args[:processors].inject(@queued_for_write[:original]) do |file, processor|
            log("Processing #{name} #{file} in the #{processor} processor.")
            Paperclip.processor(processor).make(file, args.merge(:instance => @instance))
          end
        rescue PaperclipError => e
          log("An error was received while processing: #{e.inspect}")
          (@errors[:processing] ||= []) << e.message if @whiny
        end
      end
    end
  end
end
=end