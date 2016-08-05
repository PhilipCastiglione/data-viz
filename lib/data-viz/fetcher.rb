require "net/http"
require "base64"

class Fetcher
  BASE_URL = "https://#{ENV["HARVEST_USERNAME"]}.harvestapp.com".freeze
  TASKS_ENDPOINT = "/tasks".freeze
  ENTRIES_ENDPOINT = "/people/#{ENV["HARVEST_USER_ID"]}/entries".freeze

  attr_accessor :date

  def initialize(date)
    self.date = date
  end

  # fetches and returns tasks from harvest
  def tasks
    uri = URI(BASE_URL + TASKS_ENDPOINT)

    make_request(uri)
  end

  # fetches and returns entries from harvest
  def entries
    uri = URI(BASE_URL + ENTRIES_ENDPOINT + days_query)

    make_request(uri)
  end

  private

  def days_query
    "?from=#{ENV["HARVEST_START"]}&to=#{date}"
  end

  def credentials
    Base64.strict_encode64 "#{ENV["HARVEST_EMAIL"]}:#{ENV["HARVEST_PW"]}"
  end

  # takes a uri and executes a get request with harvest's required headers
  def make_request(uri)
    request = Net::HTTP::Get.new uri

    request["Authorization"] = "Basic #{credentials}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request request
    end
  end
end
