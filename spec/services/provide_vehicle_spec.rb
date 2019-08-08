require "rails_helper"

RSpec.describe ProvideVehicle do
  describe ".execute" do
    let(:result) { described_class.execute(vin) }
    let(:vin) { Faker::Vehicle.vin }

    context "when the vehicle is not yet cached" do
      before do
        expect(Fleetio.client).to receive(:find_vehicle_by_vin).with(vin).and_return(fleetio_vehicle)
      end

      let(:fleetio_vehicle) { build_fleetio_vehicle("vin" => vin) }

      it "saves the new vehicle" do
        expect { result }.to change { Vehicle.count }.by(1)
      end

      it "queues up the job to calculate and cache fuel efficiency" do
        expect(VehicleFuelEfficiencyJob).to receive(:perform_later)
        result
      end

      it "returns the new vehicle" do
        expect(result).to be_an_instance_of(Vehicle)
        expect(result.vin).to eq(vin)
      end
    end

    context "when the vehicle is already cached" do
      before do
        expect(Fleetio.client).not_to receive(:find_vehicle_by_vin)
      end

      let!(:vehicle) { create(:vehicle, vin: vin) }

      it "does not try to save the vehicle" do
        result
        expect(Vehicle.count).to eq(1)
      end

      it "does not queue up the job to calculate and cache fuel efficiency" do
        expect(VehicleFuelEfficiencyJob).not_to receive(:perform_later)
        result
      end

      it "returns the existing vehicle" do
        expect(result).to eq(vehicle)
      end
    end

    context "when the API call errors" do
      before do
        expect(Fleetio.client).to receive(:find_vehicle_by_vin).with(vin).and_raise(Fleetio::ApiError)
      end

      it "does not try to save the vehicle" do
        result
        expect(Vehicle.count).to eq(0)
      end

      it "does not queue up the job to calculate and cache fuel efficiency" do
        expect(VehicleFuelEfficiencyJob).not_to receive(:perform_later)
        result
      end

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
