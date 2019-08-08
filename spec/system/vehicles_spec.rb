require "rails_helper"

def stub_credential(key, value)
  allow(Rails.application).to receive(:credentials).and_return(OpenStruct.new(key.to_sym => value))
end

RSpec.describe "Landing Page", type: :system do
  before do
    stub_credential(:fleetio, {auth_token: "FAKE", account_token: "FAKE"})
    visit "/vehicles"
  end

  context "initial state" do
    it "prompts the user to get started" do
      expect(page).to have_content("Nothing to see here")
      expect(page).to have_content("Start by searching above")
    end
  end

  context "user execute a search" do
    context "and nothing is found" do
      before do
        expect(ProvideVehicle).to receive(:execute).with(vin).and_return(nil)
        fill_in "vin", with: vin
        click_button "Search"
      end

      let(:vin) { Faker::Vehicle.vin }

      it "takes the user to the search results page" do
        expect(current_path).to include(search_vehicles_path)
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
        click_button "Search"
      end

      it "takes the user to the search results page" do
        expect(current_path).to include(search_vehicles_path)
      end

      it "displays the search results" do
        expect(page).to have_selector("#vehicle_card")
        within("#search_results") do
          expect(page).to have_content(fleetio_vehicle[:make])
          expect(page).to have_content(fleetio_vehicle[:model])
          expect(page).to have_content(fleetio_vehicle[:vin])
        end
      end
    end
  end
end
