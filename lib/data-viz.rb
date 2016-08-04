require 'rubygems'
require 'bundler'
Bundler.require
Dotenv.load

require_relative './data-viz/fetch'
require_relative './data-viz/present'
require_relative './data-viz/transform'

class DataViz
  def call
    p 'wat'
    p ENV['SECRET_THING']
  end
end

DataViz.new.call
