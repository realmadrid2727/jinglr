module JinglesHelper

  def jingle_track_list(jingle)
    output = ""
    jingle.jingles.each do |track|
      output += (track.id.to_s + ",")
    end
    return output
  end
  
  def jingle_connection_icon(jingle)
    icon = ""
    case jingle.connection_type
      when "origin"
        icon = "icon-beaker bg-primary"
      when "origin_master"
        icon = "icon-beaker bg-info"
      when "parent"
        icon = "icon-music bg-info"
      when "child"
        icon = "icon-plus bg-success"
    end
    
    content_tag(:i, '', class: "time-icon #{icon}", title: t("jingles.connections.#{jingle.connection_type}"), data: {toggle: "tooltip"})
  end
end
