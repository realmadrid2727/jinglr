class Jingle < ActiveRecord::Base
  include Extends::Sox
  include Extends::Waveform
  include Extends::JinglePath
  include Extends::Merge
  include Extends::NotificationJingle
  include Extends::TagScope
  include Rails.application.routes.url_helpers
  include PublicActivity::Model
  
  
  attr_accessor :force_create,
                :connection_type, # Used in the connection method to determine the associated model
                :child_offset, # Saves state of child_offset for merge track object
                :parent_offset, # Same, for parent
                :absolute_offset, # Offset, from 0, rather than relative to the previous/next track
                :offset # Normalized offset used for merging tracks
  
  # TO DO duration being saved for jingle is for either the original or merge, but not both
  
  belongs_to :user
  belongs_to :parent, class_name: "Jingle"
  has_many :comments, class_name: "JingleComment", dependent: :destroy
  has_many :likes, class_name: "JingleLike", dependent: :destroy
  has_many :favorites, class_name: "JingleFavorite", dependent: :destroy
  # TO DO think about how deleting a jingle will affect merged tracks
  has_many :child_merges, class_name: "JingleMerge", foreign_key: "parent_jingle_id"
  has_many :parent_merges, class_name: "JingleMerge", foreign_key: "child_jingle_id" 
  has_many :jingles, through: :child_merges, class_name: "Jingle", source: :child_jingle
  has_many :parents, through: :parent_merges, class_name: "Jingle", source: :parent_jingle
  has_many :origins, class_name: "JingleOrigin", foreign_key: "parent_id", dependent: :destroy
  has_many :origin_masters, class_name: "JingleOrigin", foreign_key: "jingle_id", dependent: :destroy
  has_many :notifications, -> { where(target_type: 'Jingle') }, class_name: "Notification",
           foreign_key: "target_id"
  has_many :notices, -> { where(notice_type: 'Jingle') }, class_name: "Notification",
           foreign_key: "notice_id", dependent: :destroy
  
  scope :active, -> { where(active: true, state: "complete") }
  scope :inactive, -> { where(active: false) }
  scope :merged, -> { where("jingle_merges.state = '#{JingleMerge::MERGE_STATE['merge']}'") }
  scope :pending, -> { where("jingle_merges.state = '#{JingleMerge::MERGE_STATE['pending']}'") }
  scope :declined, -> { where("jingle_merges.state = '#{JingleMerge::MERGE_STATE['decline']}'") }
  scope :current_hashtags, -> { where(created_at: (Time.now - 10.days)..(Time.now.end_of_day)) }
  scope :processing, -> { where(state: "processing") }
  
  # Sort scopes
  scope :newest, -> { order("latest_at DESC") }
  scope :date_range, ->(start_at, end_at) { where(created_at: start_at..end_at) }
  # ======== TO DO ========
  # Get a solid top ranked algorithm going based on number of likes, favorites, comments, and time active
  scope :most_favorites, ->(start_at, end_at) { 
    select("jingles.id, jingles.user_id, jingles.parent_id, jingles.desc, jingles.jingle_likes_count,
      jingles.jingle_comments_count, jingles.jingle_tracks_count, jingles.created_at,
      jingles.track_file_name, jingles.track_content_type, jingles.track_file_size, jingles.track_updated_at,
      jingles.updated_at, jingles.latest_at, jingles.original_track_duration, jingles.track_duration,
      jingles.active, jingles.state, count(jingle_favorites.id) AS count_all").
    where(created_at: start_at..end_at).
    references(:favorites).
    joins(:favorites).
    group("jingles.id").
    order("count_all DESC").
    limit(1000)
  }
  scope :most_likes, ->(start_at, end_at) {
    select("jingles.id, jingles.user_id, jingles.parent_id, jingles.desc, jingles.jingle_likes_count,
      jingles.jingle_comments_count, jingles.jingle_tracks_count, jingles.created_at,
      jingles.track_file_name, jingles.track_content_type, jingles.track_file_size, jingles.track_updated_at,
      jingles.updated_at, jingles.latest_at, jingles.original_track_duration, jingles.track_duration,
      jingles.active, jingles.state, count(jingle_likes.id) AS count_all").
    where(created_at: start_at..end_at).
    references(:likes).
    joins(:likes).
    group("jingles.id").
    order("count_all DESC").
    limit(1000)
  }
  
  
  WAVEFORM_OPTS = {
    color: :transparent,
    background_color: "#e1e2ec", # 4d5467
    #width: 800,
    #height: 250,
    width: 1800,
    height: 280,
    method: :peak,
    force: true
  }
  
  tracked
  acts_as_followable
  acts_as_taggable
  acts_as_taggable_on :hashtags
  
  has_attached_file :track,
    url: "/assets/:class/:id/:attachment/:style.:extension",
    path: ":rails_root/public/assets/:class/:id/:attachment/:style.:extension",
    styles: {
      original: {
        params: "",
        format: "mp3",
        processors: [:sox]
      },
      waveform: {
        format: :png,
        convert_options: WAVEFORM_OPTS,
        processors: [:waveform]
      }
    }#,
    #processors: [:sox]
  
  process_in_background :track
  
  validates_attachment :track,
    #presence: true,
    content_type: {
      content_type: %r{^audio/(?:mp3|mpeg|mpeg3|mpg|x-mp3|x-mpeg|x-mpeg3|x-mpegaudio|x-mpg|wav|aif|aiff|ogg|x-ogg|aac|aacp|3gpp|3gpp2|mp4|mpeg4-generic|MP4A-LATM|m4a|x-m4a)$}
    }
  
  before_create  :fill_in_defaults
  before_destroy :decrement_user_jingles_count!,
                 :clear_association!,
                 :remove_files,
                 prepend: true
  after_create   :update_latest_timestamp!
                 #:update_duration!
  #after_create :generate_waveform
  
  # Callback not working: https://github.com/thoughtbot/paperclip/issues/671
  #after_track_post_process :mark_completed!

  # TO DO
  # Create a sweeper that deletes inactive jingles (jingles with a track, but no desc, therefore not visible to anyone)
  # that have been inactive for 24 hours.
  def to_jq_upload
    {
      "name" => read_attribute(:track_file_name),
      "size" => read_attribute(:track_file_size),
      "url" => track.url(:original),
      "waveform_url" => waveform_url,
      "add_track_remote_url" => add_track_remote_jingle_path(self),
      "id" => self.id,
      "delete_url" => jingle_path(self),
      "delete_type" => "DELETE"
    }
  end
  
  # Sets a jingle to active and updates the user's jingle counter
  def activate(text)
    if text.length > 0 && text.length <= APP_CONFIG["jingle_desc_maxlength"]
      update_attributes(desc: text, active: true)
      user.update_attribute(:jingles_count, user.jingles_count + 1)
      merge_tracks_if_necessary
      add_notification
      return true
    end
    
    false
  end
  
  def has_parent?
    !parent_id.blank?
  end
  
  def has_children?
    jingles.length > 0
  end
  
  def processing?
    state == "processing"
  end
  
  def complete?
    state == "complete" && File.exist?(waveform_path(false))
  end
  
  # Check if a latest track already exists
  def merge_exists?
    file = assets_path + latest_basename
    File.exist?(file)
  end
  
  # Check if the jingle has been merged with another
  def merged_with?(jingle)
    JingleMerge.check_for('merge', self, jingle)
  end
  
  # Check if the merges have had their files processed
  def merges_processed?(is_parent = true)
    # If it was made from origin, return true
    return true if has_origins?
    
    # If self has a parent, make it what we check this against
    j = is_parent ? self : parent
    
    status = [j.complete?]
    j.child_merges.each do |m|
      status << m.child_jingle.complete?
    end
    if status.uniq.length > 1
      return false
    else
      return status.uniq.pop
    end
  end
  
  def child_to?(jingle)
    jingle.id == parent_id
  end
  
  def parent_to?(jingle)
    jingle.parent_id == id
  end
  
  # Checks if it was made from existing jingles
  def has_origins?
    origins.length > 0
  end
  
  # Finds out whether a jingle is liked by a specific user
  def liked_by?(u)
    u.likes.pluck(:jingle_id).each do |l|
      return true if l == id
    end
    
    return false
  end
  
  # Finds out whether a jingle is favorited by a specific user
  def favorited_by?(u)
    u.favorites.pluck(:jingle_id).each do |f|
      return true if f == id
    end
    
    return false
  end
  
  # TO DO need to incorporate origins that are jingle_id showing where it was used
  # Get the jingle connections
  def connections
    origins.map{|o| o.jingle.connection_type = "origin"; o.jingle} +
      jingles.merged.map{|j| j.connection_type = "child"; j} + 
      origin_masters.map{|o| o.parent.connection_type = "origin_master"; o.parent} + 
      parents.merged.map{|j| j.connection_type = "parent"; j}.sort_by(&:created_at)
  end
  
  
  
  
  
  def create_merge_notification!(jingle, notice_type)
    Notification.create(
      target_id: id,
      target_type: "Jingle",
      notice_id: jingle.id,
      notice_type: notice_type,
      user_id: jingle.user_id,
      notifier_id: user_id
    )
  end
  
  def view_merge_request_notification!(jingle)
    n = Notification.where({
      target_type: "Jingle",
      target_id: id,
      notice_type: "Jingle",
      notice_id: jingle.id
    })[0]
    n ? n.view! : true
  end
  
  
  # File system
  def rename_merge_file(jingle)
    status = false
    while (status == false)
      begin
        File.rename(merge_path(jingle), latest_path(true))
        status = true
      rescue Errno::ENOENT
        # File doesn't exist, probably due to resubmitting the merge accept
        # At any rate, there's nothing we can do, so just return false
        # so the delayed worker tries again
        status = false
      end
    end
    return true
  end
  
  def delete_merge_file(jingle)
    begin
      File.delete(merge_path(jingle))
    rescue Errno::ENOENT
      true
    end
  end
  
  
  # Association?
  def pending_child_jingles_for(u)
    user_jingle_ids = u.jingles.pluck(:id)
    jingle_ids = jingles.pending.pluck(:id)
    return Jingle.find(jingle_ids & user_jingle_ids)
  end
  
  
  def mark_completed!
    update_attribute(:state, "complete")
  end
  
  def mark_processing!
    update_attribute(:state, "processing")
  end
  
  #################
  # Class methods #
  #################
  class << self
    def all_parents
      where("parent_id IS NULL")
    end
    
    #def most_favorited(start_at = (Time.now - 1.month), end_at = (Time.now))
      
    #end
    
    ########
    # TAGS #
    ########
    def latest_tags
      current_hashtags.hashtag_counts.order("count DESC").limit(8)
    end
  end
  
private
  #############
  # Callbacks #
  #############
  def fill_in_defaults
    self.stat = "" if self.stat.nil?
  end
  
  def update_jingle_tracks_count!
    update_attribute(:jingle_tracks_count, jingle_tracks_count + 1)
  end
  
  def decrement_user_jingles_count!
    # Only decrement if it was an active jingle
    if active?
      user.update_attribute(:jingles_count, user.jingles_count - 1)
      if parent && parent.merged_with?(self)
        parent.update_attribute(:jingle_tracks_count, parent.jingle_tracks_count - 1)
      end
    end
  end
  
  # Only add a notification if it's a track
  def add_notification
    if parent
      unless user_id == parent.user_id
        Notification.create(
          target_id: parent.id,
          target_type: "Jingle",
          notice_id: id,
          notice_type: "Jingle",
          user_id: parent.user_id,
          notifier_id: user_id
        )
      end
    end
  end
  
  def clear_association!
    # Clear the association to a jingle
    jingles.each {|j| j.update_attribute(:parent_id, nil) if parent_to?(j)}
    child_merges.each {|m| m.destroy}
    parent_merges.each {|m| m.destroy}
    # TO DO remove notifications sent out by this jingle
  end
  
  def update_latest_timestamp!
    update_attribute(:latest_at, Time.now)
  end
  
  
  
  # If this is a new track being added, combine the audio files
  def merge_tracks_if_necessary
    if parent
      #parent.child_merges.each {|m| m.jingle.mark_processing!}
      parent.mark_processing!
      delay.combine_tracks
      delay.auto_merge_if_necessary
      create_merge_association!
    end
  end
  
  # Check if this track has been merged before
  # If it has, don't merge again. "forcing" it to pass
  # only forces validation to pass, so the track can
  # be posted standalone.
  def can_merge_track?(force = false)
    if JingleMerge.check_for('decline,pending', self.id, self.parent_id)
      if force
        return true
      else
        return false
      end
    else
      return true
    end
  end
  
  def remove_files
    begin
      if parent
        parent.delete_merge_file(self) # Remove the merge file if the proposed track is deleted and not activated
      end
      Dir.foreach(assets_path) {|f| fn = File.join(assets_path, f); File.delete(fn) if f != '.' && f != '..'}
      Dir.rmdir(assets_path)
    rescue Errno::ENOENT
      true
    end
  end
end
