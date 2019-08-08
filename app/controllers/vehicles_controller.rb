class VehiclesController < ApplicationController
  def index
    @vin = session[:vin]
    @remote_vehicle = nil

    if @vin.present?
      @remote_vehicle = Fleetio.client.find_vehicle_by_vin(session[:vin])
    end

    if @remote_vehicle.present?
      @vehicle = Vehicle.new(@remote_vehicle.slice("make", "model", "color", "vin", "year"))
      @vehicle.fleetio_id = @remote_vehicle["id"]
    end
  end

  def search
    session[:vin] = params[:vin]
    index
  end
end
