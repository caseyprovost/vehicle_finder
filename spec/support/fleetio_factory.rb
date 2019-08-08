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
end

RSpec.configure do |config|
  config.include(FleetioFactory)
end
