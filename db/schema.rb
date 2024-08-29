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

ActiveRecord::Schema[7.0].define(version: 2024_08_28_085603) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "booking_fields", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "field_id", null: false
    t.date "date", null: false
    t.time "start_time"
    t.time "end_time"
    t.float "total"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "paymentStatus", default: 1
    t.text "cancellation_reason"
    t.index ["field_id"], name: "index_booking_fields_on_field_id"
    t.index ["user_id"], name: "index_booking_fields_on_user_id"
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "rating_id", null: false
    t.string "content"
    t.integer "parent_id"
    t.boolean "isHidden", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["rating_id"], name: "index_comments_on_rating_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "favorites", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "favoritable_type", null: false
    t.bigint "favoritable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["favoritable_type", "favoritable_id"], name: "index_favorites_on_favoritable"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "fields", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.float "price", null: false
    t.integer "grass", default: 0
    t.integer "capacity", default: 7
    t.time "open_time", default: "2000-01-01 08:00:00"
    t.time "close_time", default: "2000-01-01 12:00:00"
    t.integer "block_time", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address", default: "10 Thanh Xuan"
  end

  create_table "ratings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "field_id", null: false
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_ratings_on_field_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "timelines", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_timelines_on_user_id"
  end

  create_table "use_vouchers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "voucher_id", null: false
    t.bigint "booking_field_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_field_id"], name: "index_use_vouchers_on_booking_field_id"
    t.index ["voucher_id"], name: "index_use_vouchers_on_voucher_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.integer "role", default: 0, null: false
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.string "activation_digest"
    t.datetime "activation_sent_at"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vouchers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.float "value", null: false
    t.date "expired_date", null: false
    t.integer "status", default: 0, null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "used_with_other", default: false
    t.index ["code"], name: "index_vouchers_on_code", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "booking_fields", "fields"
  add_foreign_key "booking_fields", "users"
  add_foreign_key "comments", "ratings"
  add_foreign_key "comments", "users"
  add_foreign_key "favorites", "users"
  add_foreign_key "ratings", "fields"
  add_foreign_key "ratings", "users"
  add_foreign_key "timelines", "users"
  add_foreign_key "use_vouchers", "booking_fields"
  add_foreign_key "use_vouchers", "vouchers"
end
