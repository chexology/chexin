class CreateCheckIns < ActiveRecord::Migration[7.0]
  def change
    create_table :check_ins do |t|
      t.references :property, null: false, foreign_key: true
      t.references :guest, null: false, foreign_key: true
      t.string :item_description, null: false
      t.string :claim_code, null: false
      t.string :status, null: false, default: "checked_in"
      t.datetime :ready_at

      t.timestamps
    end
    add_index :check_ins, [:property_id, :claim_code], unique: true
  end
end
