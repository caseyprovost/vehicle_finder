module FleetioFactory
  def build_fleetio_vehicle(attributes = {})
    {
      "id" => Faker::Number.number(digits: 5),
      "make" => Faker::Vehicle.make,
      "model" => Faker::Vehicle.model,
      "vin" => Faker::Vehicle.vin,
      "year" => Faker::Vehicle.year,
      "color" => Faker::Vehicle.color,
    }.merge(attributes)
  end

  def build_fleetio_fuel_entries(vehicle_id, count = 1)
    fuel_entries = []

    count.times do
      fuel_entries << {
        "id" => Faker::Number.number(digits: 5),
        "vehicle_id" => vehicle_id,
        "us_gallons" => Faker::Number.decimal(l_digits: 2, r_digits: 2).to_s,
        "usage_in_mi" => Faker::Number.decimal(l_digits: 3, r_digits: 2).to_s,
      }
    end

    fuel_entries
  end
end

RSpec.configure do |config|
  config.include(FleetioFactory)
end
