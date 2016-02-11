class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifier, class_name: "User", foreign_key: "notifier_id"
  belongs_to :parent, foreign_key: "target_id"
  belongs_to :jingle, foreign_key: "notice_id"
  
  scope :unread, -> { where(viewed: false) }
  scope :read, -> { where(viewed: true) }
  scope :no_merge_requests, -> { where("notice_type != 'Jingle'") }
  scope :merge_requests, -> { where(notice_type: "Jingle") }
  
  JINGLE_TYPE = ->(ttype) { ttype == "Jingle" || ttype == "JingleUpdate" }
  
  include Rails.application.routes.url_helpers
  
  def self.unread?
    unread.count > 0
  end
  
  def view!
    update_attribute(:viewed, true)
  end
  
  def unview!
    update_attribute(:viewed, false)
  end
  
  # Retrieves the next unread notification relative to self
  # Returns false if none found
  def next_notification
    result = user.notifications.where("id > #{id} AND viewed IS FALSE")
    if result.blank?
      return false
    else
      return result[0]
    end
  end
  
  # Retrieves the previous unread notification relative to self
  # Returns false if none found
  def prev_notification
    result = user.notifications.where("id < #{id} AND viewed IS FALSE")
    if result.blank?
      return false
    else
      return result[0]
    end
  end
  
  
  # Check types
  def is_jingle?
    notice_type == "Jingle"
  end
  
  def is_follow?
    notice_type == "Follow"
  end
  
  def is_jingle_accept?
    notice_type == "JingleAccept"
  end
  
  def is_jingle_decline?
    notice_type == "JingleDecline"
  end
  
  def is_jingle_merge?
    notice_type == "JingleDecline"
  end
  
  def desc(display = true)
    person = display ? notifier.display_name : nil
    ttype = target_type.underscore
    
    case notice_type
      when "Jingle"
        I18n::t("users.notifications.#{ttype}.merge_request", user: person)
      when "JingleAccept"
        I18n::t("users.notifications.#{ttype}.merge_accept", user: person)
       when "JingleDecline"
        I18n::t("users.notifications.#{ttype}.merge_decline", user: person)
      when "JingleLike"
        I18n::t("users.notifications.#{ttype}.like", user: person)
      when "JingleComment"
        I18n::t("users.notifications.#{ttype}.comment", user: person)
      when "JingleOrigin"
        I18n::t("users.notifications.#{ttype}.origin_create", user: person)
      when "JingleMerge"
        I18n::t("users.notifications.#{ttype}.merge", user: person)
      when "Follow"
        I18n::t("users.notifications.#{ttype}.follow", user: person)
    end
  end
  
  def url
    case target_type
      when JINGLE_TYPE
        open_type = "tracks" # Set a default, because it applies to origins too
        open_type = (notice_type == "JingleComment") ? "comments" : "tracks"
        open_jingle_path(Jingle.find(target_id), open: open_type)
        open_jingle_path(Jingle.find(target_id), open: open_type)
      when "User"
        profile_path(User.find(target_id).username)
      else
        "#"
    end
    
    rescue ActiveRecord::RecordNotFound
      false
  end
  
  def decline_reason
    object = JingleMerge.where({
      child_jingle_id: notice_id,
      parent_jingle_id: target_id,
      state: JingleMerge::MERGE_STATE['decline']
    }).first
    return (object && object.reason) ? object.reason : ""
  end
  
  def decline_reason?
    not decline_reason.blank?
  end
  
  class << self
    def view_set!(array)
      array.each {|n| n.update_attribute(:viewed, true) unless n.viewed?}
    end
  end
end

