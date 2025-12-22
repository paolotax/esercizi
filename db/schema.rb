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

ActiveRecord::Schema[8.1].define(version: 2025_12_22_075055) do
  create_table "account_join_codes", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "role", default: "student", null: false
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0, null: false
    t.integer "usage_limit", default: 100, null: false
    t.index ["account_id"], name: "index_account_join_codes_on_account_id"
    t.index ["code"], name: "index_account_join_codes_on_code", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "external_account_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["external_account_id"], name: "index_accounts_on_external_account_id", unique: true
  end

  create_table "classe_memberships", force: :cascade do |t|
    t.integer "classe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["classe_id", "user_id"], name: "index_classe_memberships_on_classe_id_and_user_id", unique: true
    t.index ["classe_id"], name: "index_classe_memberships_on_classe_id"
    t.index ["user_id"], name: "index_classe_memberships_on_user_id"
  end

  create_table "classi", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "anno_scolastico"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name", "anno_scolastico"], name: "index_classi_on_account_id_and_name_and_anno_scolastico", unique: true
    t.index ["account_id"], name: "index_classi_on_account_id"
    t.index ["teacher_id"], name: "index_classi_on_teacher_id"
  end

  create_table "corsi", force: :cascade do |t|
    t.integer "account_id"
    t.string "codice", null: false
    t.datetime "created_at", null: false
    t.text "descrizione"
    t.string "nome", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_corsi_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_corsi_on_account_id"
    t.index ["codice"], name: "index_corsi_on_codice", unique: true
  end

  create_table "discipline", force: :cascade do |t|
    t.integer "account_id"
    t.string "codice", null: false
    t.string "colore"
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.datetime "updated_at", null: false
    t.integer "volume_id", null: false
    t.index ["account_id"], name: "index_discipline_on_account_id"
    t.index ["volume_id"], name: "index_discipline_on_volume_id"
  end

  create_table "esercizi", force: :cascade do |t|
    t.integer "account_id"
    t.string "category"
    t.text "content", default: "{}"
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.text "description"
    t.string "difficulty"
    t.datetime "published_at"
    t.string "share_token"
    t.string "slug", null: false
    t.text "tags", default: "[]"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.index ["account_id", "created_at"], name: "index_esercizi_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_esercizi_on_account_id"
    t.index ["category"], name: "index_esercizi_on_category"
    t.index ["creator_id"], name: "index_esercizi_on_creator_id"
    t.index ["published_at"], name: "index_esercizi_on_published_at"
    t.index ["share_token"], name: "index_esercizi_on_share_token", unique: true
    t.index ["slug"], name: "index_esercizi_on_slug", unique: true
  end

  create_table "esercizio_attempts", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "esercizio_id", null: false
    t.text "results", default: "{}"
    t.float "score"
    t.datetime "started_at"
    t.string "student_identifier"
    t.integer "time_spent"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["account_id", "user_id"], name: "index_esercizio_attempts_on_account_id_and_user_id"
    t.index ["account_id"], name: "index_esercizio_attempts_on_account_id"
    t.index ["esercizio_id", "student_identifier"], name: "idx_on_esercizio_id_student_identifier_efe29ead75"
    t.index ["esercizio_id"], name: "index_esercizio_attempts_on_esercizio_id"
    t.index ["student_identifier"], name: "index_esercizio_attempts_on_student_identifier"
    t.index ["user_id"], name: "index_esercizio_attempts_on_user_id"
  end

  create_table "esercizio_templates", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "default_config", default: "{}"
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0
    t.index ["category"], name: "index_esercizio_templates_on_category"
    t.index ["name"], name: "index_esercizio_templates_on_name"
  end

  create_table "identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_identities_on_email_address", unique: true
  end

  create_table "magic_links", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "identity_id", null: false
    t.string "purpose", default: "sign_in"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_magic_links_on_code", unique: true
    t.index ["expires_at"], name: "index_magic_links_on_expires_at"
    t.index ["identity_id"], name: "index_magic_links_on_identity_id"
  end

  create_table "pagine", force: :cascade do |t|
    t.integer "account_id"
    t.string "base_color"
    t.datetime "created_at", null: false
    t.integer "disciplina_id", null: false
    t.integer "numero", null: false
    t.integer "posizione", default: 0
    t.string "slug", null: false
    t.string "sottotitolo"
    t.string "titolo"
    t.datetime "updated_at", null: false
    t.string "view_template"
    t.index ["account_id"], name: "index_pagine_on_account_id"
    t.index ["disciplina_id"], name: "index_pagine_on_disciplina_id"
    t.index ["slug"], name: "index_pagine_on_slug", unique: true
  end

  create_table "search_records", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "disciplina_id"
    t.integer "pagina_id"
    t.integer "searchable_id", null: false
    t.string "searchable_type", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "volume_id"
    t.index ["disciplina_id"], name: "index_search_records_on_disciplina_id"
    t.index ["pagina_id"], name: "index_search_records_on_pagina_id"
    t.index ["searchable_type", "searchable_id"], name: "index_search_records_on_searchable"
    t.index ["searchable_type", "searchable_id"], name: "index_search_records_on_searchable_type_and_searchable_id", unique: true
    t.index ["volume_id"], name: "index_search_records_on_volume_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "identity_id", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["identity_id"], name: "index_sessions_on_identity_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "account_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "identity_id"
    t.string "name", null: false
    t.string "role", default: "student", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["account_id", "identity_id"], name: "index_users_on_account_id_and_identity_id", unique: true
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["identity_id"], name: "index_users_on_identity_id"
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "volumi", force: :cascade do |t|
    t.integer "account_id"
    t.integer "classe"
    t.integer "corso_id", null: false
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.integer "posizione", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_volumi_on_account_id"
    t.index ["corso_id"], name: "index_volumi_on_corso_id"
  end

  add_foreign_key "account_join_codes", "accounts"
  add_foreign_key "classe_memberships", "classi", column: "classe_id"
  add_foreign_key "classe_memberships", "users"
  add_foreign_key "classi", "accounts"
  add_foreign_key "classi", "users", column: "teacher_id"
  add_foreign_key "corsi", "accounts"
  add_foreign_key "discipline", "accounts"
  add_foreign_key "discipline", "volumi"
  add_foreign_key "esercizi", "accounts"
  add_foreign_key "esercizi", "users", column: "creator_id"
  add_foreign_key "esercizio_attempts", "accounts"
  add_foreign_key "esercizio_attempts", "esercizi"
  add_foreign_key "esercizio_attempts", "users"
  add_foreign_key "magic_links", "identities"
  add_foreign_key "pagine", "accounts"
  add_foreign_key "pagine", "discipline"
  add_foreign_key "search_records", "discipline"
  add_foreign_key "search_records", "pagine"
  add_foreign_key "search_records", "volumi"
  add_foreign_key "sessions", "identities"
  add_foreign_key "users", "accounts"
  add_foreign_key "users", "identities"
  add_foreign_key "volumi", "accounts"
  add_foreign_key "volumi", "corsi"

  # Virtual tables defined in this database.
  # Note that virtual tables may not work with other database engines. Be careful if changing database.
