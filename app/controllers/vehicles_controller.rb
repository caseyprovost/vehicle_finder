class VehiclesController < ApplicationController
  helper_method :allow_save?

  def index
    setup_view_context
  end

  def search
    session[:vin] = params[:vin]
    setup_view_context
    render :index
  end

  private

  def allow_save?
    @vehicle.present? && current_user.present? && !current_user.vehicles.where(id: @vehicle.id).exists?
  end

  def setup_view_context
    @vin = session[:vin]
    @remote_vehicle = nil

    if @vin.present?
      @vehicle = Vehicle.find_by(vin: @vin)
    end

    if @vehicle.nil? && @vin.present?
      @remote_vehicle = Fleetio.client.find_vehicle_by_vin(session[:vin])

      if @remote_vehicle
        @vehicle = Vehicle.build_from_fleetio_vehicle(@remote_vehicle)
        @vehicle.save!
      end
    end

    @saved_vehicles = current_user.present? ? current_user.vehicles : []
  end
end
