FactoryBot.define do
  factory :vehicle do
    make { Faker::Vehicle.make }
    model { Faker::Vehicle.model }
    vin { Faker::Vehicle.vin }
    year { Faker::Vehicle.year }
    color { Faker::Vehicle.color }
    fleetio_id { Faker::Number.number(digits: 5) }
  end
end
