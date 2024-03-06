# frozen_script_literal: true
require 'erb'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'time'
require 'i18n'
require 'meteoalarm'
Dir['./src/weather_air/*.rb'].each { |file| require file }

module WeatherAir
  class << self
    def run
      I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
      I18n.config.available_locales = %i[en bs]
      I18n.default_locale = :en

      # weather
      weather = WeatherAir::WeatherClient.new
      current_weather = weather.current_weather_data
      (forecast_today, weather_forecast) = weather.weather_forecast_data

      # meteoalarm
      (current_alarms, future_alarms) = weather.active_meteoalarms

      # air quality index
      aqi = WeatherAir::AirQualityIndex.new

      ks_aqi = aqi.aqi_by_ks
      eko_akcija = aqi.aqi_by_ekoakcija

      city_pollutants = aqi.city_pollutants_aqi
      stations_pollutants_aqi = aqi.stations_pollutants_aqi_data

      style = File.read("src/style.css")
      js_script = File.read('src/script.js')
      scrollBtn_script =  File.read('src/scrollBtnScript.js')
      template = ERB.new(File.read('src/template.html.erb'))
      english = template.result(binding)

      feed = { current_weather:, forecast_today:, weather_forecast:, stations_pollutants_aqi:, city_pollutants: }.to_json
      sa_aqi = { city_pollutants: }.to_json
      ms_aqi = { stations_pollutants_aqi: }.to_json

      I18n.locale = :bs
      current_weather = weather.current_weather_data(I18n.locale)
      (forecast_today, weather_forecast) = weather.weather_forecast_data(I18n.locale)
      ks_aqi = aqi.aqi_by_ks(I18n.locale)
      bosnian = template.result(binding) 
      [bosnian, english, feed, sa_aqi, ms_aqi]
    end

    def last_update 
      I18n.localize(Time.now + (1*60*60), format: :default)
    end

    def text_to_class(text)
      case text
      when "Dobar"
        "good"
      when "Umjereno zagađen"
        "moderate"
      when "Nezdrav za osjetljive grupe"
        "unhealthy_for_sensitive_groups"
      when "Nezdrav"
        "unhealthy"
      when "Vrlo nezdrav"
        "very_unhealthy"
      when "Opasan"
        "hazardous"
      end
    end

  end
end
