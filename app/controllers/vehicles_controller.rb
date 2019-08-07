class VehiclesController < ApplicationController
  def index
    if params[:vin]
      session[:vin] = params[:vin]
    end

    @vin = session[:vin]
    @remote_vehicle = fleetio_client.find_vehicle_by_vin(session[:vin]).first

    if @remote_vehicle.present?
      @vehicle = Vehicle.new(@remote_vehicle.slice("make", "model", "color", "vin", "year"))
      @vehicle.fleetio_id = @remote_vehicle["id"]
    end
  end

  def show
  end

  private

  def fleetio_client
    @fleetio_client ||= Fleetio.new(
      Rails.application.credentials.fleetio[:auth_token],
      Rails.application.credentials.fleetio[:account_token]
    )
  end
end
