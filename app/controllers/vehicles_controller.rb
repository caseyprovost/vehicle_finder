class VehiclesController < ApplicationController
  def index
    if params[:vin]
      session[:vin] = params[:vin]
    end

    @vin = session[:vin]
    @vehicle = @vin.present? ? Vehicle.find_by(vin: @vin) : nil
  end

  def show
  end
end
