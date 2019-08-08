class CreateUserVehicles < ActiveRecord::Migration[6.0]
  def change
    create_table :user_vehicles do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :vehicle, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :user_vehicles, [:user_id, :vehicle_id], unique: true
  end
end
