# frozen_script_literal: true
require 'erb'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'time'
Dir['./src/modules/*.rb'].each { |file| require file }

class WeatherAir
  include Aqi
 # include Weather

  def run
    # weather
    weather = WeatherClient.new
    current_weather = weather.current_weather_data
    weather_forecast = weather.weather_forecast_data
    # air quality index
    stations_pollutants_aqi = stations_pollutants_aqi_data
    city_pollutants = city_pollutants_aqi(stations_pollutants_aqi)
  
    style = File.read("src/style.css")
    template = ERB.new(File.read('src/template.html.erb'))
    template.result(binding) 
  end

  def last_update 
    Time.now.getlocal('+01:00').to_datetime.strftime('%A (%B %d, %Y) %I:%M %P (%Z)')
  end
end
