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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120320154128) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "castings", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "piece_id",                      :null => false
    t.boolean  "is_original", :default => true
    t.datetime "updated_at"
  end

  add_index "castings", ["id"], :name => "index_castings_on_id"
  add_index "castings", ["piece_id"], :name => "index_castings_on_piece_id"
  add_index "castings", ["user_id"], :name => "index_castings_on_user_id"

  create_table "setup_configurations", :force => true do |t|
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_heroku",        :default => false
    t.string   "s3_sub_folder"
    t.integer  "account_id"
  end

  add_index "setup_configurations", ["account_id"], :name => "index_setup_configurations_on_account_id"
    
  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "documents", :force => true do |t|
    t.string   "doc_file_name"
    t.string   "doc_content_type"
    t.integer  "doc_file_size"
    t.integer  "piece_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "documents", ["id"], :name => "index_documents_on_id"
  add_index "documents", ["piece_id"], :name => "index_documents_on_piece_id"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.datetime "happened_at"
    t.integer  "duration"
    t.string   "event_type"
    t.integer  "video_id"
    t.integer  "piece_id"
    t.string   "locked",         :default => "none",   :null => false
    t.string   "state",          :default => "normal"
    t.text     "description"
    t.string   "created_by"
    t.string   "modified_by"
    t.datetime "updated_at"
    t.text     "performers"
    t.datetime "created_at"
    t.boolean  "highlighted",    :default => false
    t.boolean  "inherits_title", :default => false
    t.integer  "rating",         :default => 0
    t.integer  "parent_id"
    t.integer  "account_id"
  end

  add_index "events", ["id"], :name => "index_events_on_id"
  add_index "events", ["piece_id"], :name => "index_events_on_piece_id"
  add_index "events", ["video_id"], :name => "index_events_on_video_id"
  add_index "events", ["account_id"], :name => "index_events_on_account_id"
  

  create_table "events_tags", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "tag_id"
  end

  add_index "events_tags", ["event_id", "tag_id"], :name => "index_events_tags_on_event_id_and_tag_id"

  create_table "events_users", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "user_id"
  end

  add_index "events_users", ["event_id"], :name => "index_events_users_on_event_id"
  add_index "events_users", ["user_id"], :name => "index_events_users_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.text     "message"
    t.integer  "from_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "messages", ["from_id"], :name => "index_messages_on_from_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"
  add_index "messages", ["account_id"], :name => "index_messages_on_account_id"
  
  create_table "meta_infos", :force => true do |t|
    t.datetime "created_at"
    t.string   "created_by"
    t.integer  "piece_id"
    t.string   "title"
    t.text     "description"
    t.integer  "account_id"
  end
  add_index "meta_infos", ["account_id"], :name => "index_meta_infos_on_account_id"
  
  create_table "notes", :force => true do |t|
    t.datetime "created_at"
    t.string   "created_by"
    t.text     "note"
    t.integer  "event_id"
    t.string   "img"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "notes", ["event_id"], :name => "index_notes_on_event_id"
  add_index "notes", ["id"], :name => "index_notes_on_id"
  add_index "notes", ["account_id"], :name => "index_notes_on_account_id"

  create_table "photos", :force => true do |t|
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "piece_id"
    t.string   "path"
    t.boolean  "has_thumb",            :default => false
    t.integer  "account_id"
  end

  add_index "photos", ["id"], :name => "index_photos_on_id"
  add_index "photos", ["piece_id"], :name => "index_photos_on_piece_id"
  add_index "photos", ["account_id"], :name => "index_photos_on_account_id"

  create_table "pieces", :force => true do |t|
    t.datetime "created_at"
    t.string   "title"
    t.datetime "updated_at"
    t.string   "modified_by"
    t.string   "short_name"
    t.boolean  "is_active",   :default => true
    t.integer  "account_id"
  end

  add_index "pieces", ["id"], :name => "index_pieces_on_id"
  add_index "pieces", ["account_id"], :name => "index_pieces_on_account_id"

  create_table "sub_scenes", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "happened_at"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "sub_scenes", ["event_id"], :name => "index_sub_scenes_on_event_id"
  add_index "sub_scenes", ["account_id"], :name => "indesub_sceness_ub_sceneson_account_id"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "piece_id"
    t.string  "tag_type",   :default => "normal"
    t.integer "account_id"
  end

  add_index "tags", ["id"], :name => "index_tags_on_id"
  add_index "tags", ["piece_id"], :name => "index_tags_on_piece_id"
  add_index "tags", ["account_id"], :name => "index_tags_on_account_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "email",                     :limit => 100
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password_digest"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "role_name"
    t.boolean  "notes_on",                                 :default => true
    t.boolean  "markers_on",                               :default => true
    t.integer  "refresh_pref",                             :default => 0
    t.string   "truncate",                                 :default => "more"
    t.boolean  "inherit_cast",                             :default => false
    t.datetime "last_login"
    t.text     "scratchpad"
    t.boolean  "is_performer",                             :default => true
  end

  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["account_id"], :name => "index_users_on_account_id"

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.datetime "recorded_at"
    t.integer  "duration"
    t.integer  "rating",      :default => 0
    t.text     "meta_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "piece_id"
    t.boolean  "is_uploaded", :default => false
    t.integer  "account_id"
  end

  add_index "videos", ["id"], :name => "index_videos_on_id"
  add_index "videos", ["piece_id"], :name => "index_videos_on_piece_id"
  add_index "videos", ["title"], :name => "index_videos_on_title"
  add_index "videos", ["account_id"], :name => "index_videos_on_account_id"

end
