class RemoveUserIdFromEsercizi < ActiveRecord::Migration[8.1]
  def change
    remove_column :esercizi, :user_id, :integer
  end
end
