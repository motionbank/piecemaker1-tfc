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

ActiveRecord::Schema.define(:version => 20120429114245) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "time_zone",  :default => "Berlin"
  end

  create_table "archive_snapshots", :force => true do |t|
    t.text      "snapshot"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "assemblages", :force => true do |t|
    t.integer   "piece_id"
    t.timestamp "created_at"
    t.string    "created_by"
    t.text      "block_list"
    t.string    "title"
    t.integer   "piece_duration", :default => 3600
    t.integer   "pre_roll",       :default => 0
    t.integer   "start_time",     :default => 0
    t.integer   "post_roll",      :default => 0
    t.boolean   "grid",           :default => true
    t.boolean   "overlap_check",  :default => false
    t.boolean   "constrained",    :default => false
    t.boolean   "warning",        :default => false
    t.boolean   "track_cues",     :default => true
    t.boolean   "track_undos",    :default => true
    t.timestamp "updated_at"
  end

  create_table "block_redos", :force => true do |t|
    t.text      "blocks"
    t.integer   "position"
    t.integer   "assemblage_id"
    t.string    "edit_type"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "block_redos", ["assemblage_id"], :name => "index_block_redos_on_assemblage_id"

  create_table "block_undos", :force => true do |t|
    t.text      "blocks"
    t.integer   "position"
    t.integer   "assemblage_id"
    t.string    "edit_type"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.text      "clone_data"
  end

  add_index "block_undos", ["assemblage_id"], :name => "index_block_undos_on_assemblage_id"

  create_table "blocklists", :force => true do |t|
    t.timestamp "created_at"
    t.string    "created_by"
    t.string    "event_id"
    t.string    "title"
    t.integer   "duration",   :default => 120
    t.string    "div_class",  :default => "e9f"
    t.integer   "left",       :default => 400
    t.integer   "used",       :default => 0
    t.integer   "piece_id"
    t.text      "cast"
    t.boolean   "dependent",  :default => false
    t.string    "event_type", :default => "dance"
    t.timestamp "updated_at"
  end

  add_index "blocklists", ["id"], :name => "index_blocklists_on_id"
  add_index "blocklists", ["piece_id"], :name => "index_blocklists_on_piece_id"

  create_table "blocks", :force => true do |t|
    t.timestamp "created_at"
    t.string    "created_by"
    t.integer   "event_id"
    t.string    "title"
    t.string    "parent_id"
    t.timestamp "updated_at"
    t.integer   "start_time"
    t.integer   "duration"
    t.integer   "left"
    t.string    "div_class",     :default => "e9f"
    t.string    "description"
    t.string    "modified_by"
    t.integer   "grouped",       :default => 0
    t.integer   "blocklist_id"
    t.integer   "assemblage_id"
    t.integer   "track_id"
    t.text      "cast"
    t.integer   "z_index",       :default => 100
    t.integer   "cued_by_id"
    t.boolean   "is_clone",      :default => false
    t.boolean   "dependent",     :default => false
    t.string    "block_type"
    t.integer   "scene_id"
  end

  add_index "blocks", ["assemblage_id"], :name => "index_blocks_on_assemblage_id"
  add_index "blocks", ["blocklist_id"], :name => "index_blocks_on_blocklist_id"
  add_index "blocks", ["cued_by_id"], :name => "index_blocks_on_cued_by_id"
  add_index "blocks", ["event_id"], :name => "index_blocks_on_event_id"
  add_index "blocks", ["id"], :name => "index_blocks_on_id"
  add_index "blocks", ["scene_id"], :name => "index_blocks_on_scene_id"
  add_index "blocks", ["track_id"], :name => "index_blocks_on_track_id"

  create_table "castings", :force => true do |t|
    t.integer   "performer_id",                   :null => false
    t.integer   "piece_id",                       :null => false
    t.boolean   "is_original",  :default => true
    t.integer   "cast_number",  :default => 1
    t.timestamp "updated_at"
  end

  add_index "castings", ["id"], :name => "index_castings_on_id"
  add_index "castings", ["performer_id"], :name => "index_castings_on_performer_id"
  add_index "castings", ["piece_id"], :name => "index_castings_on_piece_id"

  create_table "configurations", :force => true do |t|
    t.integer   "location_id"
    t.string    "time_zone"
    t.boolean   "use_auto_video",    :default => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "read_only",         :default => false
    t.boolean   "use_heroku",        :default => false
    t.string    "s3_sub_folder"
    t.integer   "default_piece_id"
    t.text      "file_locations"
    t.integer   "desired_on_time"
    t.integer   "min_entrances"
    t.integer   "max_entrances"
    t.integer   "min_entrance_time"
    t.integer   "max_entrance_time"
    t.integer   "account_id"
  end

  create_table "cueings", :force => true do |t|
    t.integer   "cuer_id"
    t.integer   "cuee_id"
    t.string    "trigger"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "cueings", ["cuee_id"], :name => "index_cueings_on_cuee_id"
  add_index "cueings", ["cuer_id"], :name => "index_cueings_on_cuer_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer   "priority",   :default => 0
    t.integer   "attempts",   :default => 0
    t.text      "handler"
    t.text      "last_error"
    t.timestamp "run_at"
    t.timestamp "locked_at"
    t.timestamp "failed_at"
    t.string    "locked_by"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "account_id"
  end

  create_table "documents", :force => true do |t|
    t.string    "doc_file_name"
    t.string    "doc_content_type"
    t.integer   "doc_file_size"
    t.integer   "piece_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "account_id"
  end

  add_index "documents", ["id"], :name => "index_documents_on_id"
  add_index "documents", ["piece_id"], :name => "index_documents_on_piece_id"

  create_table "events", :force => true do |t|
    t.string    "title"
    t.timestamp "happened_at"
    t.integer   "dur"
    t.string    "event_type"
    t.integer   "video_id"
    t.integer   "piece_id"
    t.string    "locked",         :default => "none",   :null => false
    t.string    "state",          :default => "normal"
    t.text      "description"
    t.string    "created_by"
    t.string    "modified_by"
    t.timestamp "updated_at"
    t.text      "performers"
    t.timestamp "created_at"
    t.boolean   "highlighted",    :default => false
    t.boolean   "inherits_title", :default => false
    t.string    "location"
    t.integer   "rating",         :default => 0
    t.integer   "parent_id"
    t.integer   "account_id"
  end

  add_index "events", ["id"], :name => "index_events_on_id"
  add_index "events", ["piece_id"], :name => "index_events_on_piece_id"
  add_index "events", ["video_id"], :name => "index_events_on_video_id"

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

  create_table "locations", :force => true do |t|
    t.string "location"
  end

  create_table "messages", :force => true do |t|
    t.integer   "user_id"
    t.text      "message"
    t.integer   "from_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "account_id"
  end

  add_index "messages", ["from_id"], :name => "index_messages_on_from_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "meta_infos", :force => true do |t|
    t.timestamp "created_at"
    t.string    "created_by"
    t.integer   "piece_id"
    t.string    "title"
    t.text      "description"
    t.integer   "account_id"
  end

  create_table "notes", :force => true do |t|
    t.timestamp "created_at"
    t.string    "created_by"
    t.text      "note"
    t.integer   "event_id"
    t.string    "img"
    t.timestamp "updated_at"
    t.string    "private_note"
    t.integer   "account_id"
  end

  add_index "notes", ["event_id"], :name => "event_id"
  add_index "notes", ["event_id"], :name => "index_notes_on_event_id"
  add_index "notes", ["id"], :name => "index_notes_on_id"

  create_table "performances", :force => true do |t|
    t.integer   "location_id"
    t.timestamp "performance_date"
    t.string    "title"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "performances", ["location_id"], :name => "index_performances_on_location_id"

  create_table "performers", :force => true do |t|
    t.string    "first_name"
    t.string    "last_name"
    t.string    "short_name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "user_id"
    t.boolean   "is_current", :default => true
  end

  add_index "performers", ["id"], :name => "index_performers_on_id"
  add_index "performers", ["user_id"], :name => "index_performers_on_user_id"

  create_table "photos", :force => true do |t|
    t.string    "picture_file_name"
    t.string    "picture_content_type"
    t.integer   "picture_file_size"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "piece_id"
    t.string    "path"
    t.boolean   "has_thumb",            :default => false
    t.integer   "account_id"
  end

  add_index "photos", ["id"], :name => "index_photos_on_id"
  add_index "photos", ["piece_id"], :name => "index_photos_on_piece_id"

  create_table "pieces", :force => true do |t|
    t.timestamp "created_at"
    t.string    "title"
    t.timestamp "updated_at"
    t.string    "modified_by"
    t.string    "short_name"
    t.boolean   "is_active",   :default => true
    t.integer   "account_id"
  end

  add_index "pieces", ["id"], :name => "index_pieces_on_id"

  create_table "scenes", :force => true do |t|
    t.string    "title"
    t.integer   "assemblage_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "scenes", ["assemblage_id"], :name => "index_scenes_on_assemblage_id"
  add_index "scenes", ["id"], :name => "index_scenes_on_id"

  create_table "showings", :force => true do |t|
    t.integer "piece_id"
    t.integer "performance_id"
  end

  add_index "showings", ["performance_id"], :name => "index_showings_on_performance_id"
  add_index "showings", ["piece_id"], :name => "index_showings_on_piece_id"

  create_table "sub_scenes", :force => true do |t|
    t.string    "title"
    t.text      "description"
    t.timestamp "happened_at"
    t.integer   "event_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "account_id"
  end

  add_index "sub_scenes", ["event_id"], :name => "index_sub_scenes_on_event_id"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "piece_id"
    t.string  "tag_type",   :default => "normal"
    t.integer "account_id"
  end

  add_index "tags", ["id"], :name => "index_tags_on_id"
  add_index "tags", ["piece_id"], :name => "index_tags_on_piece_id"

  create_table "tracks", :force => true do |t|
    t.string    "title"
    t.integer   "assemblage_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "color",         :default => "99c"
    t.integer   "position"
    t.string    "track_type"
  end

  add_index "tracks", ["assemblage_id"], :name => "index_tracks_on_assemblage_id"
  add_index "tracks", ["id"], :name => "index_tracks_on_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.integer  "role_id",                                  :default => 1
    t.boolean  "is_performer",                             :default => false
    t.string   "role_name"
    t.boolean  "notes_on",                                 :default => true
    t.boolean  "markers_on",                               :default => true
    t.integer  "refresh_pref",                             :default => 0
    t.string   "truncate",                                 :default => "more"
    t.boolean  "inherit_cast",                             :default => false
    t.datetime "last_login"
    t.text     "scratchpad"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password_digest"
    t.integer  "account_id"
  end

  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["role_id"], :name => "index_users_on_role_id"

  create_table "video_recordings", :force => true do |t|
    t.integer   "piece_id"
    t.integer   "video_id"
    t.boolean   "primary",    :default => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "video_recordings", ["piece_id"], :name => "index_video_recordings_on_piece_id"
  add_index "video_recordings", ["video_id"], :name => "index_video_recordings_on_video_id"

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
  add_index "videos", ["title"], :name => "index_videos_on_title"

end
