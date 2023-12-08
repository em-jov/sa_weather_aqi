# frozen_script_literal: true
require 'erb'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'time'
Dir['./src/modules/*.rb'].each { |file| require file }

class WeatherAir
  include AqiGuide
  include Weather

  def run
    current_weather = current_weather_data
    latest_aqi_values = latest_pollutant_values_by_monitoring_stations
    pollutants = current_air_pollution_for_city(latest_aqi_values)
    weather_forecast = forecast

    style = File.read("src/style.css")
    template = ERB.new(File.read('src/template.html.erb'))
    template.result(binding) 
  end

  def last_update 
    Time.now.getlocal('+01:00').to_s
  end
end
