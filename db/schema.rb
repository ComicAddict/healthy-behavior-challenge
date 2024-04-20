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

ActiveRecord::Schema[7.0].define(version: 2024_04_19_234923) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "challenge_genericlists", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "challenge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_challenge_genericlists_on_challenge_id"
    t.index ["task_id"], name: "index_challenge_genericlists_on_task_id"
  end

  create_table "challenge_trainees", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.bigint "challenge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_challenge_trainees_on_challenge_id"
    t.index ["trainee_id"], name: "index_challenge_trainees_on_trainee_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.string "name", null: false
    t.date "startDate", null: false
    t.date "endDate", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "instructor_id"
    t.index ["instructor_id"], name: "index_challenges_on_instructor_id"
  end

  create_table "deactivated_trainees", force: :cascade do |t|
    t.string "full_name"
    t.integer "height_feet"
    t.integer "height_inches"
    t.float "weight"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_deactivated_trainees_on_user_id"
  end

  create_table "forum_categories", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "color", default: "000000"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "forum_posts", id: :serial, force: :cascade do |t|
    t.integer "forum_thread_id"
    t.integer "user_id"
    t.text "body"
    t.boolean "solved", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "forum_subscriptions", id: :serial, force: :cascade do |t|
    t.integer "forum_thread_id"
    t.integer "user_id"
    t.string "subscription_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "forum_threads", id: :serial, force: :cascade do |t|
    t.integer "forum_category_id"
    t.integer "user_id"
    t.string "title", null: false
    t.string "slug", null: false
    t.integer "forum_posts_count", default: 0
    t.boolean "pinned", default: false
    t.boolean "solved", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "instructor_referrals", force: :cascade do |t|
    t.string "token", limit: 40
    t.datetime "expires"
    t.boolean "is_used"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.index ["token"], name: "index_instructor_referrals_on_token", unique: true
    t.index ["user_id"], name: "index_instructor_referrals_on_user_id"
  end

  create_table "instructors", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_instructors_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "taskName"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "saved_status", default: 0
    t.float "numbers", default: [], array: true
  end

  create_table "todolist_tasks", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.string "status"
    t.bigint "trainee_id", null: false
    t.bigint "challenge_id", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "numbers", default: [], array: true
    t.index ["challenge_id"], name: "index_todolist_tasks_on_challenge_id"
    t.index ["task_id"], name: "index_todolist_tasks_on_task_id"
    t.index ["trainee_id"], name: "index_todolist_tasks_on_trainee_id"
  end

  create_table "trainees", force: :cascade do |t|
    t.string "full_name"
    t.float "weight"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "height_feet"
    t.integer "height_inches"
    t.index ["user_id"], name: "index_trainees_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "moderator"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "challenge_genericlists", "challenges"
  add_foreign_key "challenge_genericlists", "tasks"
  add_foreign_key "challenge_trainees", "challenges"
  add_foreign_key "challenge_trainees", "trainees"
  add_foreign_key "challenges", "instructors"
  add_foreign_key "deactivated_trainees", "users"
  add_foreign_key "forum_posts", "forum_threads"
  add_foreign_key "forum_posts", "users"
  add_foreign_key "forum_subscriptions", "forum_threads"
  add_foreign_key "forum_subscriptions", "users"
  add_foreign_key "forum_threads", "forum_categories"
  add_foreign_key "forum_threads", "users"
  add_foreign_key "instructor_referrals", "users"
  add_foreign_key "instructors", "users"
  add_foreign_key "todolist_tasks", "challenges"
  add_foreign_key "todolist_tasks", "tasks"
  add_foreign_key "todolist_tasks", "trainees"
  add_foreign_key "trainees", "users"
end
