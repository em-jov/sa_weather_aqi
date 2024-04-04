require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

require "minitest/autorun"
require_relative '../src/weather_air'
require 'webmock/minitest'
require 'timecop'
require 'dotenv/load'
require 'mocha/minitest'
require 'yaml'

