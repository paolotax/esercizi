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

ActiveRecord::Schema[8.1].define(version: 2025_11_03_095137) do
  create_table "corsi", force: :cascade do |t|
    t.string "codice", null: false
    t.datetime "created_at", null: false
    t.text "descrizione"
    t.string "nome", null: false
    t.datetime "updated_at", null: false
    t.index ["codice"], name: "index_corsi_on_codice", unique: true
  end

  create_table "discipline", force: :cascade do |t|
    t.string "codice", null: false
    t.string "colore"
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.datetime "updated_at", null: false
    t.integer "volume_id", null: false
    t.index ["volume_id"], name: "index_discipline_on_volume_id"
  end

  create_table "pagine", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "disciplina_id", null: false
    t.integer "numero", null: false
    t.integer "posizione", default: 0
    t.string "slug", null: false
    t.string "titolo"
    t.datetime "updated_at", null: false
    t.string "view_template"
    t.index ["disciplina_id"], name: "index_pagine_on_disciplina_id"
    t.index ["slug"], name: "index_pagine_on_slug", unique: true
  end

  create_table "volumi", force: :cascade do |t|
    t.integer "classe"
    t.integer "corso_id", null: false
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.integer "posizione", default: 0
    t.datetime "updated_at", null: false
    t.index ["corso_id"], name: "index_volumi_on_corso_id"
  end

  add_foreign_key "discipline", "volumi"
  add_foreign_key "pagine", "discipline"
  add_foreign_key "volumi", "corsi"
end
