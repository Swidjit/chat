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

ActiveRecord::Schema.define(version: 20170823124246) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blacklists", force: :cascade do |t|
    t.string "pattern"
    t.string "regexp"
    t.string "mode"
  end

  create_table "intents", force: :cascade do |t|
    t.string  "name"
    t.string  "response"
    t.string  "pattern"
    t.integer "grouping_id"
    t.index ["grouping_id"], name: "index_intents_on_grouping_id", using: :btree
  end

  create_table "logs", force: :cascade do |t|
    t.string "input"
    t.string "mode"
  end

  create_table "patterns", force: :cascade do |t|
    t.integer  "intent_id"
    t.string   "pattern"
    t.string   "regexp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "r1"
    t.string   "r2"
    t.string   "r3"
    t.string   "r4"
    t.index ["intent_id"], name: "index_patterns_on_intent_id", using: :btree
  end

  create_table "phrases", force: :cascade do |t|
    t.string  "str"
    t.string  "pattern"
    t.integer "age"
    t.integer "game_id"
  end

  create_table "substitutions", force: :cascade do |t|
    t.string "word"
    t.text   "synonyms", array: true
  end

  create_table "word_sets", force: :cascade do |t|
    t.string "keyword"
    t.text   "words"
  end

end
