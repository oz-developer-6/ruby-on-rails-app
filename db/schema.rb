ActiveRecord::Schema[8.1].define(version: 2026_11_02_170004) do
  create_table "homeworks", force: :cascade do |t|
    t.integer "school_id", null: false
    t.string "title", null: false
    t.string "subject", null: false
    t.text "description"
    t.integer "max_score", default: 100, null: false
    t.date "due_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date"], name: "index_homeworks_on_due_date"
    t.index ["school_id"], name: "index_homeworks_on_school_id"
    t.index ["subject"], name: "index_homeworks_on_subject"
  end

  create_table "markings", force: :cascade do |t|
    t.integer "homework_id", null: false
    t.integer "student_id", null: false
    t.decimal "score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.text "feedback"
    t.datetime "marked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["homework_id", "student_id"], name: "index_markings_on_homework_id_and_student_id", unique: true
    t.index ["homework_id"], name: "index_markings_on_homework_id"
    t.index ["status"], name: "index_markings_on_status"
    t.index ["student_id"], name: "index_markings_on_student_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_schools_on_code", unique: true
    t.index ["name"], name: "index_schools_on_name", unique: true
  end

  create_table "students", force: :cascade do |t|
    t.integer "school_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "enrollment_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_students_on_email"
    t.index ["enrollment_number"], name: "index_students_on_enrollment_number", unique: true
    t.index ["school_id"], name: "index_students_on_school_id"
  end

  add_foreign_key "homeworks", "schools"
  add_foreign_key "markings", "homeworks"
  add_foreign_key "markings", "students"
  add_foreign_key "students", "schools"
end
