require "rails_helper"

def stub_credential(key, value)
  allow(Rails.application).to receive(:credentials).and_return(OpenStruct.new(key.to_sym => value))
end

RSpec.describe "Landing Page", type: :system do
  before do
    stub_credential(:fleetio, {auth_token: "FAKE", account_token: "FAKE"})
    visit "/"
  end

  context "user is already logged in" do
  end

  context "user is not already logged in" do
    it "renders the page" do
      expect(page).to have_content("FIND YOUR WHIP")
    end

    context "and they search for a vehicle" do
      context "and nothing is found" do
        before do
          expect(ProvideVehicle).to receive(:execute).with(vin).and_return(nil)
          fill_in "vin", with: vin
          click_button "search_submit"
        end

        let(:vin) { Faker::Vehicle.vin }

        it "takes the user to the search results page" do
          expect(current_path).to include(vehicles_path)
        end

        it "informs the user there are no search results" do
          expect(page).to have_content("We're sorry")
          expect(page).to have_content("A vehicle couldn't be found")
        end
      end

      context "and a vehicle is found" do
        let!(:vin) { Faker::Vehicle.vin }
        let(:fleetio_vehicle) { {id: 1, make: "Ford", model: "F-150", year: "2010", color: "red", vin: vin} }

        before do
          expect(ProvideVehicle).to receive(:execute).with(vin).and_return(create(:vehicle, fleetio_vehicle))
          fill_in "vin", with: vin
          click_button "search_submit"
        end

        it "takes the user to the search results page" do
          expect(current_path).to include(vehicles_path)
        end

        it "displays the search results" do
          within("#search_results") do
            expect(page).to have_content(fleetio_vehicle[:make])
            expect(page).to have_content(fleetio_vehicle[:model])
            expect(page).to have_content(fleetio_vehicle[:vin])
          end
        end
      end
    end
  end
end
