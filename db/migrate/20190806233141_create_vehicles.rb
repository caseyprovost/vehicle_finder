class CreateVehicles < ActiveRecord::Migration[6.0]
  def change
    create_table :vehicles do |t|
      t.string :make, null: false
      t.string :model, null: false
      t.string :vin, null: false, index: true
      t.integer :year, null: false
      t.string :color, null: false
      t.integer :fleetio_id, null: true, index: true

      t.timestamps
    end
  end
end
