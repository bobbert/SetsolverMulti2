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

ActiveRecord::Schema.define(version: 20161101233213) do

  create_table "cardfaces", force: :cascade do |t|
    t.integer  "number"
    t.text     "color",      limit: 10
    t.text     "shading",    limit: 10
    t.text     "shape",      limit: 10
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "cards", force: :cascade do |t|
    t.integer  "cardface_id"
    t.integer  "deck_id"
    t.integer  "facedown_position"
    t.integer  "faceup_position"
    t.integer  "threecardset_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "decks", force: :cascade do |t|
    t.integer  "game_id"
    t.datetime "finished_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "games", force: :cascade do |t|
    t.integer  "selection_count"
    t.string   "name"
    t.datetime "started_at"
    t.datetime "paused_at"
    t.datetime "resumed_at"
    t.datetime "finished_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "players", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "profile_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "games_played", default: 0
    t.integer  "wins",         default: 0
    t.integer  "losses",       default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "threecardsets", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "seconds_to_find"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
