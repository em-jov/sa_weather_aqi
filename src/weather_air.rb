# frozen_script_literal: true
require 'erb'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'time'
require 'i18n'
require 'meteoalarm'
require 'sentry-ruby'
require_relative 'exception_notifier'
require_relative 'app_logger'
Dir['./src/weather_air/*.rb'].each { |file| require file }

module WeatherAir
  class << self
    def run
      logger = AppLogger.instance.logger
      Sentry.init
      I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
      I18n.config.available_locales = %i[en bs]
      I18n.default_locale = :en

      # weather
      weather = WeatherAir::WeatherClient.new
      # meteoalarms
      (current_alarms, future_alarms) = weather.meteoalarms
      # openweathermap
      sunrise_sunset = weather.owm_sunrise_sunset
      own_weather_forecast = weather.owm_weather_forecast
      # yr.no
      yr_weather_forecast = weather.yr_weather_forecast
      yr_current_weather = yr_weather_forecast[:sarajevo][:forecast]
      yr_current_weather = yr_current_weather.first if yr_current_weather.is_a?(Array)
     
      # air quality index
      aqi = WeatherAir::AirQualityIndex.new
      # fhmzbih.gov.ba
      fhmz_aqi = aqi.aqi_by_fhmz
      fhmz_citywide_aqi = aqi.citywide_aqi_by_fhmz
      # kanton sarajevo
      ks_aqi = aqi.aqi_by_ks
      # eko akcija
      ekoakcija_aqi = aqi.aqi_by_ekoakcija

      style = File.read("src/style.css")
      js_script = File.read('src/script.js')
      scrollBtn_script =  File.read('src/scrollBtnScript.js')
      template = ERB.new(File.read('src/template.html.erb'))
      english = template.result(binding)

      feed = { sunrise_sunset:, own_weather_forecast:, fhmz_aqi:, fhmz_citywide_aqi: }.to_json
      sa_aqi = { fhmz_citywide_aqi: }.to_json
      ms_aqi = { fhmz_aqi: }.to_json

      I18n.locale = :bs
      own_weather_forecast = weather.owm_weather_forecast
      bosnian = template.result(binding) 
      [bosnian, english, feed, sa_aqi, ms_aqi]
    rescue StandardError => e
      ExceptionNotifier.notify(e)  
    end

    def last_update 
      I18n.localize(Time.now, format: :default)
    end

    def utc_to_datetime(seconds)
      I18n.localize(Time.at(seconds.to_i).getlocal('+01:00'), format: :hm)
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
