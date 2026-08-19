class CreateGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :guests do |t|
      t.references :property, null: false, foreign_key: true
      t.string :name, null: false
      t.string :phone_number, null: false

      t.timestamps
    end
  end
end
