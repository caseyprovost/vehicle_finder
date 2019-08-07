class Fleetio
  include HTTParty
  base_uri 'https://secure.fleetio.com/api/v1/'

  def initialize(auth_token, account_token)\
    @auth_token = auth_token
    @account_token = account_token
  end

  def vehicles
    self.class.get("/vehicles", {
      headers: default_headers,
      debug_output: STDOUT,
    })
  end

  def find_vehicle_by_vin(vin)
    self.class.get("/vehicles", {
      headers: default_headers,
      query: { q: { vin_eq: vin } },
      debug_output: STDOUT,
    })
  end

  private

  def default_headers
    @default_headers ||= {
      "Content-Type"  => "application/json",
      "Accept"        => "application/json",
      "Authorization" => "Token token=\"#{@auth_token}\"",
      "Account-Token" => @account_token
    }
  end
end
