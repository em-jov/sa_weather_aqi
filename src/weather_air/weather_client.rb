module WeatherAir
  class WeatherClient
    # Sarajevo coordinates
    LAT = 43.8519774
    LON = 18.3866868

    UV_INDEX = { uv_low: 0.1..2,
                 uv_moderate: 2..5,
                 uv_high: 5..7,
                 uv_very_high: 7..10,
                 uv_extreme: 10.. }

    class CustomErrors < Faraday::Middleware
      def on_complete(env)
        raise RuntimeError.new(env[:response_body]) if env[:status].to_i != 200
      end
    end

    def meteoalarms
      [current_alarms, future_alarms]
    end

    def owm_sunrise_sunset
      weather_response = openweathermap_client.get('weather', { units: 'metric' })
      data = weather_response.body

      { sunrise: data.dig('sys', 'sunrise'),
        sunset: data.dig('sys','sunset') }

    rescue StandardError => exception
      ExceptionNotifier.notify(exception)  
      { error: { en: 'Error: No current sunrise/sunset data available! Please visit openweathermap.org for more information.', 
                 bs: 'Greška: Nedostupni podaci o izlasku/zalasku sunca! Posjetite openweathermap.org za više informacija.' } }
    end

    def owm_weather_forecast
      if I18n.locale == :bs
        weather_response = openweathermap_client.get('forecast', { lang: 'hr', units: 'metric' })
        weather_data = weather_response.body['list']
      else
        weather_response = openweathermap_client.get('forecast', { units: 'metric' })
        weather_data = weather_response.body['list']
      end

      today_forecast = []
      dates = {}
      weather_data.each do |e|
        key = I18n.localize(Time.at(e.dig('dt')&.to_i)&.getlocal('+01:00'), format: :short) 
        interval = { description: e.dig('weather', 0, 'description'),
                      icon: e.dig('weather', 0, 'icon'),
                      temp: e.dig('main', 'temp')&.to_f&.round,
                      rain: e.dig('rain', '3h') || 0 }
        if key == I18n.localize(Time.now + (1*60*60), format: :short)
          interval[:time] = I18n.localize(Time.parse(e.dig('dt_txt')) + (1*60*60), format: :hm)
          today_forecast << interval      
        elsif dates.key?(key) 
          dates[key] << interval 
        else
          dates[key] = [interval] 
        end
      end
      dates
      
    rescue StandardError => exception
      ExceptionNotifier.notify(exception)  
      { error: { en: 'Error: No weather forecast data available! Please visit openweathermap.org for more information.', 
                 bs: 'Greška: Nedostupni podaci o vremenskoj prognozi! Posjetite openweathermap.org za više informacija.' } }
    end

    def yr_weather
      forecast_locations = { sarajevo: { name: "Sarajevo", lat: 43.8519, lon: 18.3866, altitude: 520 },
                             trebevic: { name: "Trebević", lat: 43.8383, lon: 18.4498, altitude: 1100 },
                             igman: { name: "Igman", lat: 43.7507, lon: 18.2632, altitude: 1200 },
                             bjelasnica: { name: "Bjelašnica", lat: 43.7163, lon: 18.2870, altitude: 1287 },
                             jahorina: { name: "Jahorina" , lat: 43.7383, lon: 18.5645, altitude: 1557 }
                            }
      
      forecast_locations.each do |(k, v)|
        v[:forecast] = yr_client(v[:lat], v[:lon], v[:altitude])
      end
    end

    private

    def current_alarms
      current_alarms_unsorted = Meteoalarm::Client.alarms('BA', area: 'Sarajevo', active_now: true)
      current_alarms = remove_duplicate_alarms(current_alarms_unsorted)

      current_alarms.each do |alarms|   
        alarms[:alert][:info] = alarms[:alert][:info].each_with_object({}) do |info, result|
          result[info[:language].to_sym] = info
        end
      end
    rescue StandardError => exception
      ExceptionNotifier.notify(exception)  
      { error: { en: 'Error: No current meteoalarms data available! Please visit meteoalarm.org for more information.', 
                 bs: 'Greška: Nedostupni podaci o trenutnim meteoalarmima! Posjetite meteoalarm.org za više informacija.' } }
    end

    def future_alarms
      future_alarms_unsorted = Meteoalarm::Client.alarms('BA', area: 'Sarajevo', future_alarms: true)
      future_alarms = remove_duplicate_alarms(future_alarms_unsorted)

      future_alarms.each do |alarms|
        alarms[:start_date] = Time.parse(alarms[:alert][:info].first[:onset]).to_s
        alarms[:alert][:info] = alarms[:alert][:info].each_with_object({}) do |info, result|
          result[info[:language].to_sym] = info
        end
      end
      future_alarms.sort_by! {|element| element[:start_date]}
    rescue StandardError => exception
      ExceptionNotifier.notify(exception)  
      { error: { en: 'Error: No future meteoalarms data available! Please visit meteoalarm.org for more information.', 
                 bs: 'Greška: Nedostupni podaci o nadolazeċim meteoalarmima! Posjetite meteoalarm.org za više informacija.' } }
    end

    def remove_duplicate_alarms(unsorted_alarms)
      grouped_alarms = unsorted_alarms.group_by{|alarm| alarm[:alert][:info][0][:parameter][1][:value]}

      grouped_alarms.each do |type, alarms|
        alarms.sort_by! {|element| element[:alert][:sent]}.reverse!
        grouped_alarms[type] = alarms.first
      end

      grouped_alarms.values
    end

    def openweathermap_client 
      @openweathermap_client ||= Faraday.new(
        url: 'https://api.openweathermap.org/data/2.5/',
        params: { lat: LAT, lon: LON, appid: ENV['API_KEY'] },
        headers: { 'Content-Type' => 'application/json' }) do |f|
        f.response :json
        f.use CustomErrors
      end
    end

    def yr_client(lat, lon, altitude)
      ENV['TZ'] = 'Europe/Sarajevo'
      sitename = 'https://sarajevo-meteo.com/ https://github.com/em-jov/sa_weather_aqi'

      conn = Faraday.new(
        url: 'https://api.met.no/weatherapi/locationforecast/2.0/complete.json',
        params: { altitude: altitude, lat: lat, lon: lon },
        headers: { 'Content-Type' => 'application/json', 'User-Agent' => sitename }) do |f|
        f.response :json
        f.use CustomErrors
      end

      yr_response = conn.get()
      data = yr_response.body

      weather = []
      data["properties"]["timeseries"].each do |ts|
        utc_time = Time.parse(ts["time"])
        ts_data = { 
          time: utc_time.localtime,
          air_temperature: ts.dig("data", "instant", "details", "air_temperature")&.round,
          icon: ts.dig("data", "next_1_hours", "summary", "symbol_code"),
          precipitation_amount: ts.dig("data", "next_1_hours", "details", "precipitation_amount"),
          relative_humidity: ts.dig("data", "instant", "details", "relative_humidity"),
          uv_index: ts.dig("data", "instant", "details", "ultraviolet_index_clear_sky"),
          wind_from_direction: ts.dig("data", "instant", "details", "wind_from_direction"),
          wind_speed: ts.dig("data", "instant", "details", "wind_speed"),
        }
        weather << ts_data
      end

      forecast = weather.take(25).map do |el|
        el[:uv_class] = UV_INDEX.select{|k, v| v.include?(el[:uv_index])}&.first&.first&.to_s
        el
      end

    rescue StandardError => exception
      ExceptionNotifier.notify(exception)  
      { error: { en: 'Error: No weather forecast data available for this location! Please visit yr.no for more information.', 
                 bs: 'Greška: Nedostupni podaci o vremenskoj prognozi za ovu lokaciju! Posjetite yr.no za više informacija.' } }        
    end
  end
end




