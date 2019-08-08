class Vehicle < ApplicationRecord
  before_save :set_default_color

  def set_default_color
    self.color ||= "unknown"
  end

  def self.build_from_fleetio_vehicle(fleetio_vehicle)
    new(fleetio_vehicle.slice("make", "model", "color", "vin", "year")).tap do |vehicle|
      vehicle.fleetio_id = fleetio_vehicle["id"]
    end
  end

  def name
    "#{year} #{make} #{model}"
  end
end
