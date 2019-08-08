class UserVehicle < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
end
