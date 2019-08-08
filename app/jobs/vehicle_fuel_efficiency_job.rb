class VehicleFuelEfficiencyJob < ApplicationJob
  queue_as :default

  rescue_from(TimeoutError) do
    retry_job wait: 1.hour, queue: :default
  end

  def perform(vehicle_id)
    vehicle = Vehicle.find(vehicle_id)
    fuel_entries = Fleetio.client.total_vehicle_fuel_entries(vehicle.fleetio_id)
    gallons_sum = calculate_sum(fuel_entries, "us_gallons")
    mileage_sum = calculate_sum(fuel_entries, "usage_in_mi")
    vehicle.update!(fuel_efficiency: gallons_sum / mileage_sum)
  end

  private

  def calculate_sum(fuel_entries, attribute)
    fuel_entries.inject(0) do |sum, data|
      sum += data[attribute].present? ? BigDecimal(data[attribute]) : 0.0
    end
  end
end
