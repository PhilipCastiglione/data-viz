require 'pry' # REMOVE THIS
require "rubygems"
require "bundler"
Bundler.require
Dotenv.load

require_relative "./data-viz/fetcher"
require_relative "./data-viz/transformer"
require_relative "./data-viz/presenter"

class DataViz
  attr_accessor :fetcher, :transformer, :presenter

  def initialize
    self.fetcher = Fetcher.new
    self.transformer = Transformer.new
    self.presenter = Presenter.new
  end

  def call
    raw_tasks = fetcher.tasks
    raw_entries = fetcher.entries

    transformer.raw_tasks = raw_tasks.body
    transformer.raw_entries = raw_entries.body

    transformer.generate_csv
  end
end

DataViz.new.call
