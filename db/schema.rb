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

ActiveRecord::Schema[7.0].define(version: 2026_08_19_151541) do
  create_table "check_ins", force: :cascade do |t|
    t.integer "property_id", null: false
    t.integer "guest_id", null: false
    t.string "item_description", null: false
    t.string "claim_code", null: false
    t.string "status", default: "checked_in", null: false
    t.datetime "ready_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guest_id"], name: "index_check_ins_on_guest_id"
    t.index ["property_id", "claim_code"], name: "index_check_ins_on_property_id_and_claim_code", unique: true
    t.index ["property_id"], name: "index_check_ins_on_property_id"
  end

  create_table "guests", force: :cascade do |t|
    t.integer "property_id", null: false
    t.string "name", null: false
    t.string "phone_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_guests_on_property_id"
  end

  create_table "notification_logs", force: :cascade do |t|
    t.integer "check_in_id", null: false
    t.string "channel", default: "sms", null: false
    t.string "status", null: false
    t.string "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_in_id"], name: "index_notification_logs_on_check_in_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "time_zone", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "quiet_hours_start"
    t.time "quiet_hours_end"
    t.index ["slug"], name: "index_properties_on_slug", unique: true
  end

  add_foreign_key "check_ins", "guests"
  add_foreign_key "check_ins", "properties"
  add_foreign_key "guests", "properties"
  add_foreign_key "notification_logs", "check_ins"
end
