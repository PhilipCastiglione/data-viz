require "net/http"
require "base64"
require "date"

class Fetcher
  attr_accessor :email, :password, :uri


  def initialize
    self.email = ENV["HARVEST_EMAIL"]
    self.password = ENV["HARVEST_PW"]
    self.uri = URI(base_url + endpoint + query)
  end

  def call
    request = Net::HTTP::Get.new uri

    request["Authorization"] = "Basic #{credentials}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request request
    end
  end

  private

  def base_url
    "https://#{ENV["HARVEST_USERNAME"]}.harvestapp.com"
  end

  def endpoint
    "/people/#{ENV["HARVEST_USER_ID"]}/entries"
  end

  def query
    "?from=#{ENV["HARVEST_START"]}&to=#{Date.today.strftime("%Y%m%d")}"
  end

  def credentials
    Base64.strict_encode64 "#{email}:#{password}"
  end
end
