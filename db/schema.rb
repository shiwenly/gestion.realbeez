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

ActiveRecord::Schema.define(version: 2020_10_11_102406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "apartments", force: :cascade do |t|
    t.string "name"
    t.string "water"
    t.string "statut"
    t.bigint "building_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_apartments_on_building_id"
    t.index ["user_id"], name: "index_apartments_on_user_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.string "address"
    t.integer "number_of_flat"
    t.string "statut"
    t.bigint "user_id"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_buildings_on_company_id"
    t.index ["user_id"], name: "index_buildings_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.boolean "corporate_tax"
    t.boolean "vat"
    t.string "associe"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "statut"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.string "apartment_name"
    t.string "expense_type"
    t.date "date"
    t.string "supplier"
    t.decimal "amount_ttc", precision: 10, scale: 2
    t.decimal "amount_vat", precision: 10, scale: 2
    t.string "photo", default: "image/upload/v1598991055/default_annonce_k6x0wm.png"
    t.boolean "deductible"
    t.string "statut"
    t.bigint "user_id"
    t.bigint "building_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_expenses_on_building_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "liasses", force: :cascade do |t|
    t.date "year"
    t.string "statut"
    t.boolean "closed", default: false
    t.bigint "user_id"
    t.bigint "building_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year2"
    t.index ["building_id"], name: "index_liasses_on_building_id"
    t.index ["user_id"], name: "index_liasses_on_user_id"
  end

  create_table "rents", force: :cascade do |t|
    t.date "period"
    t.decimal "rent_paid", precision: 10, scale: 2
    t.decimal "service_charge_paid", precision: 10, scale: 2
    t.decimal "rent_ask", precision: 10, scale: 2
    t.decimal "service_charge_ask", precision: 10, scale: 2
    t.string "statut"
    t.bigint "user_id"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_payment"
    t.index ["tenant_id"], name: "index_rents_on_tenant_id"
    t.index ["user_id"], name: "index_rents_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.decimal "rent", precision: 10, scale: 2
    t.decimal "service_charge", precision: 10, scale: 2
    t.decimal "deposit", precision: 10, scale: 2
    t.string "contract", default: "image/upload/v1598991055/default_annonce_k6x0wm.png"
    t.string "inventory", default: "image/upload/v1598991055/default_annonce_k6x0wm.png"
    t.date "move_in_date"
    t.date "move_out_date"
    t.string "statut"
    t.bigint "user_id"
    t.bigint "apartment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "current_tenant", default: true
    t.index ["apartment_id"], name: "index_tenants_on_apartment_id"
    t.index ["user_id"], name: "index_tenants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "statut"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "waters", force: :cascade do |t|
    t.date "submission_date"
    t.decimal "quantity", precision: 10, scale: 2
    t.string "photo", default: "image/upload/v1598991055/default_annonce_k6x0wm.png"
    t.string "statut"
    t.bigint "user_id"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_waters_on_tenant_id"
    t.index ["user_id"], name: "index_waters_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "apartments", "buildings"
  add_foreign_key "apartments", "users"
  add_foreign_key "buildings", "companies"
  add_foreign_key "buildings", "users"
  add_foreign_key "companies", "users"
  add_foreign_key "expenses", "buildings"
  add_foreign_key "expenses", "users"
  add_foreign_key "liasses", "buildings"
  add_foreign_key "liasses", "users"
  add_foreign_key "rents", "tenants"
  add_foreign_key "rents", "users"
  add_foreign_key "tenants", "apartments"
  add_foreign_key "tenants", "users"
  add_foreign_key "waters", "tenants"
  add_foreign_key "waters", "users"
end
