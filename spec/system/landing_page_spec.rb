require "rails_helper"

RSpec.describe "Landing Page", type: :system do
  before do
    visit '/'
  end

  context "user is already logged in" do
  end

  context "user is not already logged in" do
    it 'renders the page' do
      expect(page).to have_content("FIND YOUR WHIP")
    end

    context 'and they search for a vehicle' do
      context 'and nothing is found' do
        before do
          fill_in 'vin', with: vin
          click_button 'search_submit'
        end

        let(:vin) { Faker::Vehicle.vin }

        it 'takes the user to the search results page' do
          expect(current_path).to include(vehicles_path)
        end

        it 'informs the user there are no search results' do
          expect(page).to have_content("We're sorry, we couldn't find your vehicle")
        end
      end

      context 'and a vehicle is found' do
        let!(:vehicle) { create(:vehicle) }

        before do
          fill_in 'vin', with: vehicle.vin
          click_button 'search_submit'
        end

        it 'takes the user to the search results page' do
          expect(current_path).to include(vehicles_path)
        end

        it 'displays the search results' do
          within('#search_results') do
            expect(page).to have_content(vehicle.make)
            expect(page).to have_content(vehicle.model)
            expect(page).to have_content(vehicle.vin)
          end
        end
      end
    end
  end
end
