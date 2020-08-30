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

ActiveRecord::Schema.define(version: 2020_08_30_150246) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "tenants", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.decimal "rent", precision: 10, scale: 2
    t.decimal "service_charge", precision: 10, scale: 2
    t.decimal "deposit", precision: 10, scale: 2
    t.string "contract"
    t.string "inventory"
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
    t.string "photo"
    t.string "statut"
    t.bigint "user_id"
    t.bigint "tenant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_waters_on_tenant_id"
    t.index ["user_id"], name: "index_waters_on_user_id"
  end

  add_foreign_key "apartments", "buildings"
  add_foreign_key "apartments", "users"
  add_foreign_key "buildings", "companies"
  add_foreign_key "buildings", "users"
  add_foreign_key "companies", "users"
  add_foreign_key "tenants", "apartments"
  add_foreign_key "tenants", "users"
  add_foreign_key "waters", "tenants"
  add_foreign_key "waters", "users"
end
