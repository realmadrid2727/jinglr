# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131024033157) do

  create_table "activities", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "follows", force: true do |t|
    t.integer  "followable_id",                   null: false
    t.string   "followable_type",                 null: false
    t.integer  "follower_id",                     null: false
    t.string   "follower_type",                   null: false
    t.boolean  "blocked",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "jingle_comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "jingle_id"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jingle_favorites", force: true do |t|
    t.integer  "user_id"
    t.integer  "jingle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jingle_likes", force: true do |t|
    t.integer  "user_id"
    t.integer  "jingle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jingle_merges", force: true do |t|
    t.integer  "child_jingle_id"
    t.integer  "parent_jingle_id"
    t.string   "child_type"
    t.string   "parent_type"
    t.integer  "state",            default: 0,   null: false
    t.string   "reason"
    t.float    "parent_offset",    default: 0.0, null: false
    t.float    "child_offset",     default: 0.0, null: false
    t.datetime "merged_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jingle_origins", force: true do |t|
    t.integer  "parent_id"
    t.integer  "jingle_id"
    t.float    "offset",     default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jingles", force: true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "desc"
    t.integer  "jingle_likes_count",      default: 0,            null: false
    t.integer  "jingle_favorites_count",  default: 0,            null: false
    t.integer  "jingle_comments_count",   default: 0,            null: false
    t.integer  "jingle_tracks_count",     default: 0,            null: false
    t.boolean  "active",                  default: false,        null: false
    t.datetime "latest_at"
    t.string   "state",                   default: "processing", null: false
    t.text     "stat",                                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "track_file_name"
    t.string   "track_content_type"
    t.integer  "track_file_size"
    t.datetime "track_updated_at"
    t.float    "original_track_duration"
    t.float    "track_duration",          default: 0.0
  end

  create_table "notification_settings", force: true do |t|
    t.integer  "user_id"
    t.boolean  "email_jingle_comments", default: true
    t.boolean  "email_jingle_likes",    default: true
    t.boolean  "email_jingle_merge",    default: true
    t.boolean  "email_jingle_decline",  default: true
    t.boolean  "email_jingle_accept",   default: true
    t.boolean  "email_jingle_origin",   default: true
    t.boolean  "email_jingle_update",   default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "notifier_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "notice_id"
    t.string   "notice_type"
    t.boolean  "viewed",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_feedback_categories", force: true do |t|
    t.string "name"
  end

  create_table "site_feedbacks", force: true do |t|
    t.integer  "user_id"
    t.integer  "site_feedback_category_id"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  create_table "user_details", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "location"
    t.string   "website"
    t.string   "bio"
    t.string   "track_mixer_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.integer  "uid"
    t.string   "name"
    t.string   "provider"
    t.string   "provider_token"
    t.string   "provider_token_secret"
    t.integer  "followers_count",        default: 0,  null: false
    t.integer  "following_count",        default: 0,  null: false
    t.integer  "jingles_count",          default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
