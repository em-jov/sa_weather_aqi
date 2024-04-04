# frozen_script_literal: true
require 'erb'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'time'
require 'i18n'
require 'meteoalarm'
require 'sentry-ruby'
Dir['./src/weather_air/*.rb'].each { |file| require file }

module WeatherAir
  class << self
    def run
      Sentry.init
      I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
      I18n.config.available_locales = %i[en bs]
      I18n.default_locale = :en

      # weather
      weather = WeatherAir::WeatherClient.new
      sunrise_sunset = weather.owm_sunrise_sunset
      own_weather_forecast = weather.owm_weather_forecast
      yr_weather_forecast = weather.yr_weather
      yr_current_weather = yr_weather_forecast[:sarajevo][:forecast][0]
      
      # meteoalarms
      (current_alarms, future_alarms) = weather.meteoalarms

      # air quality index
      aqi = WeatherAir::AirQualityIndex.new

      ks_aqi = aqi.aqi_by_ks
      (eko_akcija, ea_city_aqi_value, ea_city_aqi_class) = aqi.aqi_by_ekoakcija

      city_pollutants = aqi.city_pollutants_aqi
      stations_pollutants_aqi = aqi.stations_pollutants_aqi_data

      style = File.read("src/style.css")
      js_script = File.read('src/script.js')
      scrollBtn_script =  File.read('src/scrollBtnScript.js')
      template = ERB.new(File.read('src/template.html.erb'))
      english = template.result(binding)

      feed = { sunrise_sunset:, own_weather_forecast:, stations_pollutants_aqi:, city_pollutants: }.to_json
      sa_aqi = { city_pollutants: }.to_json
      ms_aqi = { stations_pollutants_aqi: }.to_json

      I18n.locale = :bs
      sunrise_sunset = weather.owm_sunrise_sunset
      own_weather_forecast = weather.owm_weather_forecast
      yr_weather_forecast = weather.yr_weather
      yr_current_weather = yr_weather_forecast[:sarajevo][:forecast][0]

      ks_aqi = aqi.aqi_by_ks
      bosnian = template.result(binding) 
      [bosnian, english, feed, sa_aqi, ms_aqi]
    rescue StandardError => e 
      Sentry.capture_exception(e)  
    end

    def last_update 
      I18n.localize(Time.now, format: :default)
    end

    def icon_path(icon)
      if I18n.locale == :en
        "../yr_icons/#{icon}.svg"
      else
        "yr_icons/#{icon}.svg"
      end
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
