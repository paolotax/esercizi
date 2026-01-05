class AddPublicToPagine < ActiveRecord::Migration[8.1]
  def change
    add_column :pagine, :public, :boolean, default: false, null: false
    add_index :pagine, :public
  end
end
