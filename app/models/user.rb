class User < ActiveRecord::Base
  # The "followers_count_cache" and "following_count_cache"
  # are called as such because the acts_as_follower gem
  # creates a couple of methods that automatically add
  # count methods with conflicting names, but it does so with
  # SQL query counts rather than just a lookup cache that speeds
  # things up.
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :twitter]
  
  has_many :jingles #, conditions: "parent_id IS NULL"
  has_many :comments, class_name: "JingleComment", dependent: :destroy
  has_many :likes, class_name: "JingleLike", dependent: :destroy
  has_many :jingle_favorites, class_name: "JingleFavorite", dependent: :destroy
  has_many :favorites, class_name: "Jingle", through: :jingle_favorites, source: :jingle
  has_many :notifications, -> { order("id DESC, created_at DESC") }, dependent: :destroy
  has_many :activities, class_name: "Notification", foreign_key: "notifier_id"
  has_one  :detail, class_name: "UserDetail", dependent: :destroy
  has_one  :notification_setting, dependent: :destroy
  
  acts_as_followable
  acts_as_follower
  acts_as_tagger
  
  include Rails.application.routes.url_helpers
             
	validates :username, uniqueness: true, format: {
              with: /\A[a-zA-Z0-9_]*\z/i,
              message: "must contain only letters, numbers, and underscores" #, unless: :new_record?
            }
  
  has_attached_file :avatar,
                    url: "/assets/:class/:id/:attachment/:style.:extension",
                    path: ":rails_root/public/assets/:class/:id/:attachment/:style.:extension",
                    default_url: "/defaults/avatar_default.jpg", #ActionController::Base.helpers.asset_path("avatar_default.jpg"),
                    styles: {normal: "400x400#", small: "128x128#"}
  
  after_create :create_user_details
  
  def to_jq_upload
    {
      "name" => read_attribute(:avatar_file_name),
      "size" => read_attribute(:avatar_file_size),
      "url" => avatar.url(:small),
      "id" => self.id,
      "delete_url" => delete_avatar_user_path(self),
      "delete_type" => "DELETE",
      "status" => I18n::t('flash.notice.update', item: I18n::t('models.thing').downcase)
    }
  end
  
  def fullname
    detail.name.blank? ? username : detail.name
  end
  
  def display_name
    fullname
  end
  
  def like(jingle)
    JingleLike.where("user_id = ? AND jingle_id = ?", id, jingle.id)[0]
  end
  
  def favorite(jingle)
    JingleFavorite.where("user_id = ? AND jingle_id = ?", id, jingle.id)[0]
  end
  
  # Alias for following?(user)
  def follows?(user)
    following?(user)
  end
  
  def add_track_to_mixer!(jingle)
    detail.add_track_to_mixer!(jingle)
  end
  
  def remove_track_from_mixer!(jingle)
    detail.remove_track_from_mixer!(jingle)
  end
  
  # Omniauth
  def self.find_for_facebook_oauth(auth, signed_in_resource = nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      # Get the avatar from the FB Graph. width/height params
      # will return the closest size
      img = open(auth.info.image+"&width=600&height=600")
      user = User.create(
        name: auth.extra.raw_info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0,20],
        avatar: img
      )
      img.close
    end
    user
  end
  
  def self.find_for_twitter_oauth(auth, signed_in_resource = nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create(
        name: auth.extra.raw_info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  #############
  # Callbacks #
  #############
  def create_user_details
    UserDetail.create(user_id: id, name: name)
    NotificationSetting.create(user_id: id)
  end
end
