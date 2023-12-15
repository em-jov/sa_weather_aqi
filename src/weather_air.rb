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
    # weather
    current_weather
    weather_forecast
    # air quality index
    stations_pollutants_aqi
    city_pollutants = city_pollutants_aqi(stations_pollutants_aqi)
  
    style = File.read("src/style.css")
    template = ERB.new(File.read('src/template.html.erb'))
    template.result(binding) 
  end

  def last_update 
    Time.now.getlocal('+01:00').to_s
  end
end
