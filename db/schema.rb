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

ActiveRecord::Schema[7.0].define(version: 2023_10_10_235340) do
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
  end

  create_table "todolist_tasks", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.string "status"
    t.bigint "trainee_id", null: false
    t.bigint "challenge_id", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_todolist_tasks_on_challenge_id"
    t.index ["task_id"], name: "index_todolist_tasks_on_task_id"
    t.index ["trainee_id"], name: "index_todolist_tasks_on_trainee_id"
  end

  create_table "trainees", force: :cascade do |t|
    t.string "full_name"
    t.float "height"
    t.float "weight"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_trainees_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "challenge_genericlists", "challenges"
  add_foreign_key "challenge_genericlists", "tasks"
  add_foreign_key "challenge_trainees", "challenges"
  add_foreign_key "challenge_trainees", "trainees"
  add_foreign_key "challenges", "instructors"
  add_foreign_key "instructor_referrals", "users"
  add_foreign_key "instructors", "users"
  add_foreign_key "todolist_tasks", "challenges"
  add_foreign_key "todolist_tasks", "tasks"
  add_foreign_key "todolist_tasks", "trainees"
  add_foreign_key "trainees", "users"
end
