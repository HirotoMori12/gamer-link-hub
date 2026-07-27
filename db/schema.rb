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

ActiveRecord::Schema[8.1].define(version: 2026_07_27_115442) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "guilds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "discord_guild_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_guild_id"], name: "index_guilds_on_discord_guild_id", unique: true
  end

  create_table "user_guilds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "guild_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["guild_id"], name: "index_user_guilds_on_guild_id"
    t.index ["user_id", "guild_id"], name: "index_user_guilds_on_user_id_and_guild_id", unique: true
    t.index ["user_id"], name: "index_user_guilds_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "discord_uid", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["discord_uid"], name: "index_users_on_discord_uid", unique: true
  end

  add_foreign_key "user_guilds", "guilds"
  add_foreign_key "user_guilds", "users"
end
