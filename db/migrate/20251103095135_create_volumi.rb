class CreateVolumi < ActiveRecord::Migration[8.1]
  def change
    create_table :volumi do |t|
      t.references :corso, null: false, foreign_key: true
      t.string :nome, null: false
      t.integer :classe
      t.integer :posizione, default: 0

      t.timestamps
    end
  end
end
