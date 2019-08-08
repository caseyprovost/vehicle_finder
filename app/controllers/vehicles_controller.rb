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
    @allow_save ||= @vehicle.present? && current_user.present? && !current_user.vehicles.where(id: @vehicle.id).exists?
  end

  def setup_view_context
    @vin = session[:vin]
    @remote_vehicle = nil
    @vehicle = @vin.present? ? ProvideVehicle.execute(@vin) : nil
    @saved_vehicles = current_user.present? ? current_user.vehicles : []
  end
end
