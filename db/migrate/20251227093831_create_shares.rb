# frozen_string_literal: true

class CreateShares < ActiveRecord::Migration[8.0]
  def change
    create_table :shares do |t|
      # Cosa viene condiviso (polimorfico)
      t.references :shareable, polymorphic: true, null: false

      # Con chi (delegated_type)
      t.string :recipient_type, null: false
      t.bigint :recipient_id, null: false

      # Permessi e metadata
      t.integer :permission, default: 0, null: false
      t.references :granted_by, foreign_key: { to_table: :users }
      t.datetime :expires_at

      t.timestamps
    end

    add_index :shares, [:recipient_type, :recipient_id]
    add_index :shares, [:shareable_type, :shareable_id, :recipient_type, :recipient_id],
              unique: true, name: "index_shares_unique"
  end
end
