# frozen_string_literal: true

class AddStatusToEsercizi < ActiveRecord::Migration[8.0]
  def change
    add_column :esercizi, :status, :integer, default: 0, null: false
    add_index :esercizi, :status
  end
end
