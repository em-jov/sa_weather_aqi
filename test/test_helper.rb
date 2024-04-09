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

class TestCase < Minitest::Test
  def setup
    I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
    I18n.config.available_locales = %i[en bs]
    I18n.locale = :en
  end

  def teardown
    Timecop.return
  end
end