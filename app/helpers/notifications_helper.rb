module NotificationsHelper
  def notice_class(notification)
    if notification.viewed?
      "bg-light"
    else
      "bg-white"
    end
  end
  
  def notice_label_class(notification)
    case notification.notice_type
      when "Jingle"
        "bg-info"
      when "JingleAccept"
        "bg-success"
      when "JingleDecline"
        "bg-danger"
      else
        "bg-white"
    end
  end
end
