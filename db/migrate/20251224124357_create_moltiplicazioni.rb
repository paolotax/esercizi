class CreateMoltiplicazioni < ActiveRecord::Migration[8.1]
  def change
    create_table :moltiplicazioni do |t|
      t.json :data

      t.timestamps
    end
  end
end
