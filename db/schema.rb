# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_08_29_202602) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "media", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "playlist_id", null: false
    t.text "embed_code"
    t.integer "position", default: 0, null: false
    t.string "status", default: "queued", null: false
    t.string "added_by"
    t.string "thumbnail_url"
    t.string "display_title"
    t.index ["playlist_id", "position"], name: "index_media_on_playlist_id_and_position"
    t.index ["playlist_id", "status"], name: "index_media_on_playlist_id_and_status"
    t.index ["playlist_id"], name: "index_media_on_playlist_id"
    t.index ["session_id"], name: "index_media_on_session_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_playlists_on_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "host_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "media", "playlists"
  add_foreign_key "media", "sessions"
  add_foreign_key "playlists", "sessions"
end
