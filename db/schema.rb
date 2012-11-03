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

ActiveRecord::Schema.define(:version => 20121103092357) do

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "album_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "album_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "albums", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.integer  "thumb_id"
    t.datetime "deleted_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "blog_comments", :force => true do |t|
    t.integer  "blog_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "blog_images", :force => true do |t|
    t.integer  "blog_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "blogs", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "content"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "board_comments", :force => true do |t|
    t.integer  "board_id"
    t.integer  "user_id"
    t.text     "content"
    t.string   "attach_file_name"
    t.string   "attach_content_type"
    t.integer  "attach_file_size"
    t.datetime "attach_updated_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "boards", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "attach_file_name"
    t.string   "attach_content_type"
    t.integer  "attach_file_size"
    t.datetime "attach_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "celebrations", :force => true do |t|
    t.integer  "user_id"
    t.date     "anniversary_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "geocodes", :force => true do |t|
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "histories", :force => true do |t|
    t.integer  "episode_year"
    t.integer  "episode_month"
    t.integer  "episode_day"
    t.boolean  "about_flg"
    t.text     "content"
    t.integer  "user_id"
    t.string   "src_user_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "history_comments", :force => true do |t|
    t.integer  "history_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "login_histories", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "movie_comments", :force => true do |t|
    t.integer  "movie_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "movies", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.string   "movie_file_name"
    t.string   "movie_content_type"
    t.integer  "movie_file_size"
    t.datetime "movie_updated_at"
    t.string   "thumb_file_name"
    t.string   "thumb_content_type"
    t.integer  "thumb_file_size"
    t.datetime "thumb_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "movie_type"
  end

  create_table "mutters", :force => true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "reply_id"
    t.integer  "celebration_id"
    t.datetime "for_sort_at"
    t.string   "ua"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "nices", :force => true do |t|
    t.integer  "user_id"
    t.integer  "asset_id"
    t.string   "asset_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "comment"
    t.integer  "niced_user_id"
  end

  create_table "photo_comments", :force => true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "photo_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "photos", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.integer  "album_id"
    t.datetime "exif_at"
    t.datetime "last_comment_at"
    t.datetime "deleted_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "rankings", :force => true do |t|
    t.integer  "classification"
    t.integer  "content_id"
    t.string   "content_type"
    t.integer  "nice_count"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "update_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "action_type"
    t.integer  "content_id"
    t.string   "content_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "user_exts", :force => true do |t|
    t.integer  "user_id"
    t.string   "familyname"
    t.string   "givenname"
    t.string   "nickname"
    t.integer  "sex"
    t.integer  "blood"
    t.string   "email"
    t.string   "addr1"
    t.string   "addr2"
    t.string   "addr3"
    t.string   "addr4"
    t.string   "addr_from"
    t.date     "birth_day"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "job"
    t.string   "hobby"
    t.string   "skill"
    t.string   "character"
    t.string   "jiman"
    t.string   "dream"
    t.string   "sonkei"
    t.string   "kyujitsu"
    t.string   "myboom"
    t.string   "fav_food"
    t.string   "unfav_food"
    t.string   "fav_movie"
    t.string   "fav_book"
    t.string   "fav_sports"
    t.string   "fav_music"
    t.string   "fav_game"
    t.string   "fav_brand"
    t.string   "hosii"
    t.string   "ikitai"
    t.string   "yaritai"
    t.text     "free_text"
    t.datetime "deleted_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username",               :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.integer  "role",                   :default => 2,  :null => false
    t.string   "email",                  :default => ""
    t.string   "familyname"
    t.string   "givenname"
    t.integer  "root11"
    t.integer  "generation"
    t.datetime "deleted_at"
    t.datetime "last_request_at"
    t.string   "password_salt"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
