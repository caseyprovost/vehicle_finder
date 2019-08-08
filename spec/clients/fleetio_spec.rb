require "rails_helper"

RSpec.describe Fleetio do
  let(:fleetio_url) { Rails.application.credentials.fleetio[:base_url] }
  let(:client) { Fleetio.new("FAKE", "FAKE") }
  let(:expected_headers) do
    {
      'Accept'        =>'application/json',
      'Account-Token' =>'FAKE',
      'Authorization' =>'Token token="FAKE"',
      'Content-Type'  =>'application/json'
    }
  end

  describe "handle_response" do
    context "when the request is successful" do
      let(:response) do
        instance_double(HTTParty::Response, parsed_response: [{ foo: 'bar' }], code: 200)
      end

      it 'returns the parsed response' do
        expect(client.send(:handle_response, response)).to eq([{ foo: 'bar' }])
      end
    end

    context "when the request fails" do
      let(:response) do
        instance_double(HTTParty::Response, parsed_response: "", code: 403)
      end

      it 'raises an api error' do
        expect { client.send(:handle_response, response) }.to raise_error(Fleetio::ApiError)
      end
    end
  end

  describe "#vehicles" do
    let(:fleetio_vehicle) { build_fleetio_vehicle }

    before do
      stub_request(:get, "#{fleetio_url}/vehicles").
        with(
          headers: expected_headers
        ).to_return(
          status: 200,
          body: [fleetio_vehicle].to_json,
          headers: { "Content-Type"=> "application/json" }
        )
    end

    it 'returns an array of vehicle hashes' do
      response = client.vehicles
      expect(response.first).to eq(fleetio_vehicle)
    end
  end

  describe "#find_vehicle_by_vin" do
    let(:fleetio_vehicle) { build_fleetio_vehicle }
    let(:vin) { fleetio_vehicle["vin"] }

    context "when a record is found" do
      before do
        stub_request(:get, "#{fleetio_url}/vehicles").
          with(
            query: { q: { vin_eq: vin } },
            headers: expected_headers
          ).to_return(
            status: 200,
            body: [fleetio_vehicle].to_json,
            headers: { "Content-Type"=> "application/json" }
          )
      end

      it 'return the first vehicle' do
        response = client.find_vehicle_by_vin(vin)
        expect(response).to eq(fleetio_vehicle)
      end
    end

    context "when a record is not found" do
      before do
        stub_request(:get, "#{fleetio_url}/vehicles").
          with(
            query: { q: { vin_eq: vin } },
            headers: expected_headers
          ).to_return(
            status: 200,
            body: [].to_json,
            headers: { "Content-Type"=> "application/json" }
          )
      end

      it 'returns nil' do
        response = client.find_vehicle_by_vin(vin)
        expect(response).to be_nil
      end
    end
  end
end
