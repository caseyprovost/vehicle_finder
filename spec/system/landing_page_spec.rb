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
      end

      context 'and a vehicle is found' do
      end
    end
  end
end
