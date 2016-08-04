require "rubygems"
require "bundler"
Bundler.require
Dotenv.load

require_relative "./data-viz/fetcher"
require_relative "./data-viz/transformer"
require_relative "./data-viz/presenter"

class DataViz
  def call
    fetcher = Fetcher.new
    serialized_time_entries = fetcher.call


  end
end

DataViz.new.call
