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

ActiveRecord::Schema[7.1].define(version: 2024_10_22_143231) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "media", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_media_on_session_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.bigint "media_id", null: false
    t.bigint "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_id"], name: "index_playlists_on_media_id"
    t.index ["session_id"], name: "index_playlists_on_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "host_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "media", "sessions"
  add_foreign_key "playlists", "media", column: "media_id"
  add_foreign_key "playlists", "sessions"
end
