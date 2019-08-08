class Fleetio
  include HTTParty

  attr_reader :last_response

  base_uri "https://secure.fleetio.com/api/v1/"

  class ApiError < StandardError; end

  def self.client
    @client ||= new(
      Rails.application.credentials.fleetio[:auth_token],
      Rails.application.credentials.fleetio[:account_token]
    )
  end

  def initialize(auth_token, account_token)
    @auth_token = auth_token
    @account_token = account_token
  end

  def vehicles
    response = self.class.get("/vehicles", {
      headers: default_headers,
      debug_output: STDOUT,
    })

    handle_response(response)
  end

  def vehicle_fuel_entries(vehicle_id)
    response = self.class.get("/vehicles/#{vehicle_id}/fuel_entries", {
      headers: default_headers,
      debug_output: STDOUT,
    })

    handle_response(response)
  end

  def total_vehicle_fuel_entries(vehicle_id)
    initial_response = self.class.get("/vehicles/#{vehicle_id}/fuel_entries", {
      headers: default_headers.merge("X-Pagination-Current-Page" => "1"),
      debug_output: STDOUT,
    })

    total_pages = initial_response.headers["x-pagination-total-pages"].to_i
    entries = handle_response(initial_response)
    return entries if total_pages < 2

    (2..total_pages).each do |page_number|
      response = self.class.get("/vehicles/#{vehicle_id}/fuel_entries", {
        headers: default_headers.merge("X-Pagination-Current-Page" => page_number.to_s),
        debug_output: STDOUT,
      })

      entries = entries.concat(handle_response(response))
    end

    entries
  end

  def find_vehicle_by_vin(vin)
    response = self.class.get("/vehicles", {
      headers: default_headers,
      query: {q: {vin_eq: vin}},
      debug_output: STDOUT,
    })

    handle_response(response).first
  end

  private

  def handle_response(response)
    @last_response = response

    case response.code
    when 200..205
      response.parsed_response
    else
      raise Fleetio::ApiError, "[FLEETIO-API-ERRROR] API responded with status code: #{response.code}"
    end
  end

  def default_headers
    @default_headers ||= {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Token token=\"#{@auth_token}\"",
      "Account-Token" => @account_token,
    }
  end
end
