ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), '..', 'app.rb')

require 'sinatra'
require 'rack/test'
require 'pry'

# setup test environment
set :run, false
set :raise_errors, true
set :logging, false

def app
  CSV2Sinatra
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end