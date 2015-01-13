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

ActiveRecord::Schema.define(version: 20150113195528) do

  create_table "courses", force: :cascade do |t|
    t.string   "slug",                       null: false
    t.boolean  "published",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["published"], name: "index_courses_on_published"
  add_index "courses", ["slug"], name: "index_courses_on_slug", unique: true

  create_table "units", force: :cascade do |t|
    t.integer  "course_id",                          null: false
    t.string   "slug",                               null: false
    t.boolean  "published",                          null: false
    t.boolean  "random_steps_order", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "units", ["course_id"], name: "index_units_on_course_id"
  add_index "units", ["published"], name: "index_units_on_published"
  add_index "units", ["slug"], name: "index_units_on_slug", unique: true

end
