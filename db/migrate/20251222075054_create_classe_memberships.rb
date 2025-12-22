class CreateClasseMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :classe_memberships do |t|
      t.references :classe, null: false, foreign_key: { to_table: :classi }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :classe_memberships, [:classe_id, :user_id], unique: true
  end
end
