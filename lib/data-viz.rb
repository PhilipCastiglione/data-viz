require "rubygems"
require "bundler"
Bundler.require
Dotenv.load

require "date"

require_relative ".././vendor/gruff-patch"
require_relative "./data-viz/fetcher"
require_relative "./data-viz/transformer"
require_relative "./data-viz/presenter"

class DataViz
  attr_accessor :fetcher, :transformer, :presenter

  def initialize
    date = Date.today.strftime("%Y%m%d")
    self.fetcher = Fetcher.new(date)
    self.transformer = Transformer.new(date)
    self.presenter = Presenter.new(date)
  end

  def call
    p "fetching"
    raw_tasks = fetcher.tasks
    raw_entries = fetcher.entries

    p "transforming"
    transformer.raw_tasks = raw_tasks.body
    transformer.raw_entries = raw_entries.body

    transformer.generate_csv

    p "presenting"
    presenter.generate_charts
  end

  def self.regenerate_presentation
    Dir.foreach("./csv/") do |csv|
      regex_date = csv.match(/([0-9]+)\.csv/)
      p "presenting" if regex_date
      Presenter.new(regex_date[1]).generate_charts if regex_date
    end
  end
end
