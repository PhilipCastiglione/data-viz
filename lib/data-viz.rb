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
    #serialized_time_entries = fetcher.call



  end
end

DataViz.new.call
