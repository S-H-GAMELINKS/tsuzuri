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

ActiveRecord::Schema[8.1].define(version: 2026_03_13_042511) do
  create_table "account_login_change_keys", force: :cascade do |t|
    t.datetime "deadline", null: false
    t.string "key", null: false
    t.string "login", null: false
  end

  create_table "account_password_reset_keys", force: :cascade do |t|
    t.datetime "deadline", null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "key", null: false
  end

  create_table "account_remember_keys", force: :cascade do |t|
    t.datetime "deadline", null: false
    t.string "key", null: false
  end

  create_table "account_verification_keys", force: :cascade do |t|
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "key", null: false
    t.datetime "requested_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.string "activity_pub_url", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "display_name"
    t.string "email", null: false
    t.string "fediverse_creator"
    t.string "password_hash"
    t.text "private_key_pem", null: false
    t.text "public_key_pem", null: false
    t.integer "status", default: 1, null: false
    t.text "summary"
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "username"
    t.index ["email"], name: "index_accounts_on_email", unique: true, where: "status IN (1, 2)"
    t.index ["username"], name: "index_accounts_on_username", unique: true
  end

  create_table "delivery_attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "inbox_url", null: false
    t.integer "outbound_activity_id", null: false
    t.text "response_body"
    t.integer "response_status"
    t.boolean "success", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["outbound_activity_id"], name: "index_delivery_attempts_on_outbound_activity_id"
  end

  create_table "followers", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.string "follow_activity_id", null: false
    t.integer "remote_actor_id", null: false
    t.string "state", default: "active", null: false
    t.datetime "undone_at"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_followers_on_account_id"
    t.index ["follow_activity_id"], name: "index_followers_on_follow_activity_id", unique: true
    t.index ["remote_actor_id"], name: "index_followers_on_remote_actor_id"
    t.index ["state"], name: "index_followers_on_state"
  end

  create_table "inbound_activities", force: :cascade do |t|
    t.string "activity_id"
    t.string "activity_type", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.text "raw_json", null: false
    t.integer "remote_actor_id"
    t.boolean "signature_verified", default: false, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type"], name: "index_inbound_activities_on_activity_type"
    t.index ["remote_actor_id"], name: "index_inbound_activities_on_remote_actor_id"
    t.index ["status"], name: "index_inbound_activities_on_status"
  end

  create_table "known_servers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain", null: false
    t.datetime "last_seen_at"
    t.boolean "reachable", default: true, null: false
    t.string "shared_inbox_url"
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_known_servers_on_domain", unique: true
  end

  create_table "outbound_activities", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "activity_type", null: false
    t.string "activity_uri", null: false
    t.datetime "created_at", null: false
    t.text "payload_json", null: false
    t.integer "post_id"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_outbound_activities_on_account_id"
    t.index ["activity_uri"], name: "index_outbound_activities_on_activity_uri", unique: true
    t.index ["post_id"], name: "index_outbound_activities_on_post_id"
    t.index ["status"], name: "index_outbound_activities_on_status"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "activity_pub_create_activity_uri"
    t.string "activity_pub_delete_activity_uri"
    t.string "activity_pub_object_uri"
    t.datetime "created_at", null: false
    t.text "html_body", null: false
    t.text "plaintext_body", null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "state", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_posts_on_account_id"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["state"], name: "index_posts_on_state"
  end

  create_table "remote_actors", force: :cascade do |t|
    t.string "actor_uri", null: false
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "domain", null: false
    t.string "inbox_url", null: false
    t.string "preferred_username"
    t.string "public_key_id"
    t.text "public_key_pem"
    t.string "shared_inbox_url"
    t.datetime "updated_at", null: false
    t.index ["actor_uri"], name: "index_remote_actors_on_actor_uri", unique: true
    t.index ["domain"], name: "index_remote_actors_on_domain"
  end

  create_table "self_destruct_runs", force: :cascade do |t|
    t.datetime "completed_at"
    t.string "confirmation_token"
    t.datetime "created_at", null: false
    t.integer "delivered_activities", default: 0, null: false
    t.integer "failed_activities", default: 0, null: false
    t.datetime "read_only_at"
    t.datetime "started_at"
    t.string "state", default: "pending", null: false
    t.integer "total_activities", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "account_login_change_keys", "accounts", column: "id"
  add_foreign_key "account_password_reset_keys", "accounts", column: "id"
  add_foreign_key "account_remember_keys", "accounts", column: "id"
  add_foreign_key "account_verification_keys", "accounts", column: "id"
  add_foreign_key "delivery_attempts", "outbound_activities"
  add_foreign_key "followers", "accounts"
  add_foreign_key "followers", "remote_actors"
  add_foreign_key "inbound_activities", "remote_actors"
  add_foreign_key "outbound_activities", "accounts"
  add_foreign_key "outbound_activities", "posts"
  add_foreign_key "posts", "accounts"
end
