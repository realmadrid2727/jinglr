module ApplicationHelper
  include Twitter::Extractor
  include Twitter::Autolink
  include MixerHelper
  
  def allow_remote_create?
    true
  end
  
  # link_to with optional icon
  def icon_link(title, options = {}, icon = "")
    content_tag(:a, options) do
      content_tag(:i, "", class: icon) + content_tag(:span, title)
    end
  end
  
  def render_breadcrumbs
    render partial: "shared/breadcrumbs"
  end
  
  # Format json errors
  def format_errors_for_js(errors)
    errors.join(". ") + "."
  end
  
  # Hashtags
  def parse_and_link_hashtags(text)
    extract_hashtags(text)
  end
  
  def hashtag_auto_link(text)
    begin
      auto_link(text, hashtag_url_base: hashtag_base_path + "/", hashtag_class: "label bg-dark").html_safe
    rescue
      ""
    end
  end
  
  def hashtag_format(tag)
    "#" + tag
  end
  
  def can_edit?(item)
    if user_signed_in?
      item.user_id == current_user.id
    else
      false
    end
  end
  
  def render_modal(title, partial_name, button_ok, options ={})
    render partial: "shared/modal", locals: {
      title: title,
      partial_name: partial_name,
      button_ok: button_ok,
      options: options
    }
  end
  
  def image_preloader(jingles)
    output = ""
    jingles.each do |jingle|
      output += "'#{jingle.waveform_url}',"
    end
    return output.chop
  end
  
  def show_time(time)
    output = ""
    
    if Time.now.year != time.year
      output = time.strftime("%b %d '%y@%I:%M %p")
    elsif (Time.now - time) > 1.day
      output = time.strftime("%b %d@%I:%M %p")
    else
      output = distance_of_time_in_words_to_now(time)
      output += I18n::t('time.ago')
    end
    
    content_tag(:acronym, title: time) do
      output
    end
  end
end
