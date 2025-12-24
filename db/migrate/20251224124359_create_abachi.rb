class CreateAbachi < ActiveRecord::Migration[8.1]
  def change
    create_table :abachi do |t|
      t.json :data

      t.timestamps
    end
  end
end
