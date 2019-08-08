class UserVehiclesController < ApplicationController
  def create
    @user_vehicle = current_user.user_vehicles.new(user_vehicle_params)

    if @user_vehicle.save
      flash[:success] = "Your vehicle was successfully saved"
      redirect_to vehicles_path
    else
      # TODO: do something on failure
      # render errors
    end
  end

  private

  def user_vehicle_params
    params.require(:user_vehicle).permit(:vehicle_id)
  end
end
