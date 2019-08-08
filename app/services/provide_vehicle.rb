class ProvideVehicle
  def self.execute(vin)
    new(vin).execute
  end

  def execute
    vehicle = Vehicle.find_by(vin: @vin)
    return vehicle if vehicle

    remote_vehicle = begin
                       Fleetio.client.find_vehicle_by_vin(@vin)
                     rescue
                       nil
                     end

    if remote_vehicle
      vehicle = Vehicle.build_from_fleetio_vehicle(remote_vehicle)
      vehicle.save!
      VehicleFuelEfficiencyJob.perform_later(vehicle.id)
    end

    vehicle
  end

  private

  def initialize(vin)
    @vin = vin
  end
end
