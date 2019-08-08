require "rails_helper"

RSpec.describe Fleetio do
  let(:fleetio_url) { Rails.application.credentials.fleetio[:base_url] }
  let(:client) { Fleetio.new("FAKE", "FAKE") }
  let(:expected_headers) do
    {
      "Accept" => "application/json",
      "Account-Token" => "FAKE",
      "Authorization" => 'Token token="FAKE"',
      "Content-Type" => "application/json",
    }
  end

  describe "handle_response" do
    context "when the request is successful" do
      let(:response) do
        instance_double(HTTParty::Response, parsed_response: [{foo: "bar"}], code: 200)
      end

      it "returns the parsed response" do
        expect(client.send(:handle_response, response)).to eq([{foo: "bar"}])
      end
    end

    context "when the request fails" do
      let(:response) do
        instance_double(HTTParty::Response, parsed_response: "", code: 403)
      end

      it "raises an api error" do
        expect { client.send(:handle_response, response) }.to raise_error(Fleetio::ApiError)
      end
    end
  end

  describe "#vehicles" do
    let(:fleetio_vehicle) { build_fleetio_vehicle }

    before do
      stub_request(:get, "#{fleetio_url}/vehicles")
        .with(
          headers: expected_headers
        ).to_return(
          status: 200,
          body: [fleetio_vehicle].to_json,
          headers: {"Content-Type" => "application/json"}
        )
    end

    it "returns an array of vehicle hashes" do
      response = client.vehicles
      expect(response.first).to eq(fleetio_vehicle)
    end
  end

  describe "#vehicle_fuel_entries" do
    let(:fleetio_vehicle) { build_fleetio_vehicle }
    let(:fleetio_fuel_entries) { build_fleetio_fuel_entries(fleetio_vehicle["id"], 3) }

    before do
      stub_request(:get, "#{fleetio_url}/vehicles/#{fleetio_vehicle["id"]}/fuel_entries")
        .with(
          headers: expected_headers
        ).to_return(
          status: 200,
          body: fleetio_fuel_entries.to_json,
          headers: {"Content-Type" => "application/json"}
        )
    end

    it "returns an array of fuel entry hashes" do
      response = client.vehicle_fuel_entries(fleetio_vehicle["id"])
      expect(response.count).to eq(3)
      expect(response.first).to have_key("id")
      expect(response.first).to have_key("vehicle_id")
      expect(response.first).to have_key("us_gallons")
      expect(response.first).to have_key("usage_in_mi")
    end
  end

  describe "#total_vehicle_fuel_entries" do
    let(:fleetio_vehicle) { build_fleetio_vehicle }
    let(:page_1_fuel_entries) { build_fleetio_fuel_entries(fleetio_vehicle["id"], 3) }
    let(:page_2_fuel_entries) { build_fleetio_fuel_entries(fleetio_vehicle["id"], 3) }
    let(:page_3_fuel_entries) { build_fleetio_fuel_entries(fleetio_vehicle["id"], 3) }

    before do
      stub_request(:get, "#{fleetio_url}/vehicles/#{fleetio_vehicle["id"]}/fuel_entries")
        .with(
          headers: expected_headers.merge("X-Pagination-Current-Page" => "1")
        ).to_return(
          status: 200,
          body: page_1_fuel_entries.to_json,
          headers: {
            "Content-Type" => "application/json",
            "X-Pagination-Total-Pages" => "3",
            "X-Pagination-Current-Page" => "1",
          }
        )

      stub_request(:get, "#{fleetio_url}/vehicles/#{fleetio_vehicle["id"]}/fuel_entries")
        .with(
          headers: expected_headers.merge("X-Pagination-Current-Page" => "2")
        ).to_return(
          status: 200,
          body: page_2_fuel_entries.to_json,
          headers: {
            "Content-Type" => "application/json",
            "X-Pagination-Total-Pages" => "3",
            "X-Pagination-Current-Page" => "2",
          }
        )

      stub_request(:get, "#{fleetio_url}/vehicles/#{fleetio_vehicle["id"]}/fuel_entries")
        .with(
          headers: expected_headers.merge("X-Pagination-Current-Page" => "3")
        ).to_return(
          status: 200,
          body: page_3_fuel_entries.to_json,
          headers: {
            "Content-Type" => "application/json",
            "X-Pagination-Total-Pages" => "3",
            "X-Pagination-Current-Page" => "3",
          }
        )
    end

    it "returns all the pages of fuel entries" do
      response = client.total_vehicle_fuel_entries(fleetio_vehicle["id"])
      expect(response.count).to eq(9)
    end
  end

  describe "#find_vehicle_by_vin" do
    let(:fleetio_vehicle) { build_fleetio_vehicle }
    let(:vin) { fleetio_vehicle["vin"] }

    context "when a record is found" do
      before do
        stub_request(:get, "#{fleetio_url}/vehicles")
          .with(
            query: {q: {vin_eq: vin}},
            headers: expected_headers
          ).to_return(
            status: 200,
            body: [fleetio_vehicle].to_json,
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "return the first vehicle" do
        response = client.find_vehicle_by_vin(vin)
        expect(response).to eq(fleetio_vehicle)
      end
    end

    context "when a record is not found" do
      before do
        stub_request(:get, "#{fleetio_url}/vehicles")
          .with(
            query: {q: {vin_eq: vin}},
            headers: expected_headers
          ).to_return(
            status: 200,
            body: [].to_json,
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "returns nil" do
        response = client.find_vehicle_by_vin(vin)
        expect(response).to be_nil
      end
    end
  end
end
