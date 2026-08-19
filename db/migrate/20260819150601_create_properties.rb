class CreateProperties < ActiveRecord::Migration[7.0]
  def change
    create_table :properties do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :time_zone, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :properties, :slug, unique: true
  end
end
