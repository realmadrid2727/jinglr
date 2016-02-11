Jinglr::Application.routes.draw do
  root 'site#index'
  
  # Devise auth
  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  
  devise_scope :user do
    delete 'logout' => 'sessions#destroy', as: :logout
    get 'login' => 'sessions#new', as: :login
    get 'register' => 'registrations#new', as: :register
    # Check for existence of username
    get 'username_check' => 'registrations#username_check', as: :username_check
  end
  
  # Users
  resources :user, controller: :users do
    resources :details, controller: :user_details
    
    member do
      post :upload_avatar
      delete :delete_avatar
      put :update_email
      put :update_password
      get :select_username
      put :set_username
    end
    
    collection do
      get :jingles
      get :favorites, controller: :jingle_favorites, to: :index
      get :notifications, controller: :notifications, to: :index
      get :followers, controller: :followers, to: :followers
      get :following, controller: :followers, to: :following
    end
  end
  
  # User home
  get 'user/jingles' => 'users#jingles', as: :home
  
  # Notificaitons in header
  get 'user/notifications/remote' => 'notifications#remote', as: :remote_notifications
  get 'user/notification/:id/remote' => 'notifications#remote_notification', as: :remote_notification
  # Mark notifications as viewed
  put 'user/notifications/view' => 'notifications#mark_all_viewed', as: :mark_notifications_viewed
  put 'user/notification/:id/view' => 'notifications#mark_viewed', as: :mark_notification_viewed
  put 'user/notifications/settings/update' => 'notifications#update_settings', as: :update_settings_notification
  
  # Jingles
  resources :jingles do
    resources :contributions, controller: :jingle_comments, only: [:index, :create, :destroy] do
      collection do
        get 'comments' => 'jingle_comments#comments', as: :comments
        get 'tracks' => 'jingle_comments#tracks', as: :tracks
      end
    end
    
    resources :likes, controller: :jingle_likes, only: [:create, :destroy] do
      collection do
        post :toggle
      end
    end
    resources :favorites, controller: :jingle_favorites, only: [:create, :destroy] do
      collection do
        post :toggle
      end
    end
    
    collection do
      post :add
      post :merge
      #get 'check-status' => 'jingles#check_status', as: :check_status
      #get 'merge-remote' => 'jingles#merge_remote', as: :merge_remote
      get 'new/:option' => 'jingles#new', as: :new_remote
      get 'sort/:sort' => 'jingles#index', as: :sorted
    end
    
    member do
      post 'toggle-follow' => 'jingles#toggle_follow', as: :toggle_follow
      put 'accept', as: :accept_merge
      put 'decline', as: :decline_merge
      get 'decline-confirm' => 'jingles#confirm_decline_merge', as: :confirm_decline_merge
      get 'check-status' => 'jingles#check_status', as: :check_status
      get 'check-track-status' => 'jingles#check_track_status', as: :check_track_status
      get 'merge-remote' => 'jingles#merge_remote', as: :merge_remote
      get 'add-track-remote' => 'jingles#add_track_remote', as: :add_track_remote
      get 'connections' => 'jingles#connections', as: :connections
      get 'new', as: :new_jingle_track
      get ':open' => 'jingles#show', as: :open
    end
  end
  
  # Track mixer
  resources :mixer, only: [:index, :show] do
    collection do
      get 'get/:jingle_id' => 'mixer#get_track', as: :mixer_get_track_remote
      put 'add' => 'mixer#add_track', as: :mixer_add_track_remote
      put 'remove/:jingle_id' => 'mixer#remove_track', as: :mixer_remove_track_remote
    end
  end
  
  # Feed
  get 'feed' => 'feeds#index', as: :feed
  get 'feed/sort/:sort' => 'feeds#index', as: :sorted_feed
  
  # Search
  get 'search' => 'search#show', as: :search
  get 'search/:q' => 'search#show'
  get 'search/:q/sort/:sort' => 'search#show', as: :sorted_search
  
  # Hashtags
  get 'hashtags' => 'hashtags#show', as: :hashtag_base
  get 'hashtags/:tag' => 'hashtags#show', as: :hashtag
  get 'hashtags/:tag/sort/:sort' => 'hashtags#show', as: :sorted_hashtag
  
  # Site
  get 'help' => 'site#help', as: :help
  get 'privacy' => 'site#privacy', as: :privacy
  get 'login_or_register' => 'site#login_or_register', as: :login_or_register
  get 'leave_feedback' => 'site#leave_feedback', as: :leave_feedback
  post 'leave_feedback' => 'site#leave_feedback_create', as: :leave_feedback_create
  # Catch 404 errors
  get '404' => 'site#error_404', as: :error_404
  #get '*path' => 'site#error_404', as: :error_404
  
  # Profiles
  post ':username/follow' => 'followers#toggle', as: :toggle_follow
  post ':username/follow-yes' => 'followers#create', as: :follow
  delete ':username/follow-no' => 'followers#destroy', as: :unfollow
  get ':username/followers' => 'profiles#followers', as: :profile_followers
  get ':username/following' => 'profiles#following', as: :profile_following
  get ':username' => 'profiles#show', as: :profile
  
  
end
