require "rails_helper"

RSpec.describe VehicleFuelEfficiencyJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let!(:vehicle) { create(:vehicle, fuel_efficiency: nil) }
    let(:fuel_entries) { build_fleetio_fuel_entries(vehicle.id, 3) }
    subject(:job) { described_class.perform_later(vehicle.id) }

    context "when the API returns data" do
      before do
        expect(Fleetio.client).to receive(:total_vehicle_fuel_entries).with(vehicle.fleetio_id).and_return(fuel_entries)
      end

      it "calculate and stores the vehicle's fuel efficiency" do
        perform_enqueued_jobs do
          job
          expect(vehicle.reload.fuel_efficiency).to be_present
        end
      end
    end

    context "when the API returns nil data values" do
      before do
        new_fuel_entries = fuel_entries.map { |entry|
          entry["us_gallons"] = nil
          entry["us_gallons"] = nil
          entry
        }

        expect(Fleetio.client).to receive(:total_vehicle_fuel_entries).with(vehicle.fleetio_id).and_return(new_fuel_entries)
      end

      it "does not update the fuel efficiency" do
        perform_enqueued_jobs do
          job
          expect(vehicle.reload.fuel_efficiency).to be_nil
        end
      end
    end

    context "when the API call times out" do
      before do
        allow(Fleetio.client).to receive(:total_vehicle_fuel_entries).and_raise(TimeoutError)
      end

      it "retries" do
        perform_enqueued_jobs do
          expect_any_instance_of(described_class).to receive(:retry_job).with(wait: 1.hour, queue: :default)
          job
        end
      end
    end
  end
end
