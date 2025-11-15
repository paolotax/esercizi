class AddSottotitoloAndBaseColorToPagine < ActiveRecord::Migration[8.1]
  def change
    add_column :pagine, :sottotitolo, :string
    add_column :pagine, :base_color, :string
  end
end
