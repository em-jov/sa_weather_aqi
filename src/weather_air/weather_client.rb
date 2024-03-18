module WeatherAir
  class WeatherClient
    # Sarajevo coordinates
    LAT = 43.8519774
    LON = 18.3866868

    class CustomErrors < Faraday::Middleware
      def on_complete(env)
        raise RuntimeError if env[:status].to_i != 200
      end
    end

    def initialize
      @conn = Faraday.new(
        url: 'https://api.openweathermap.org/data/2.5/',
        params: { lat: LAT, lon: LON, appid: ENV['API_KEY'] },
        headers: { 'Content-Type' => 'application/json' }) do |f|
        f.response :json
        f.use CustomErrors
      end
    end

    def current_weather_data(locale = :en)
      if locale == :bs
        weather_response = @conn.get('weather', { lang: 'hr', units: 'metric' })
        data = weather_response.body
      else
        weather_response = @conn.get('weather', { units: 'metric' })
        data = weather_response.body
      end

      { currenttemp: data.dig('main', 'temp').to_f.round,
        feelslike: data.dig('main', 'feels_like').to_f.round,
        humidity: data.dig('main', 'humidity'),
        description: data.dig('weather', 0, 'description'),
        icon: data.dig('weather', 0, 'icon'),
        rain: data.dig('rain', '1h') || 0,
        wind: data.dig('wind', 'speed'),
        sunrise: utc_to_datetime(data.dig('sys', 'sunrise')),
        sunset: utc_to_datetime(data.dig('sys','sunset')) }

    rescue StandardError => _e
      { error: { en: 'Error: No current weather data available!', 
                 bs: 'Greška: Nedostupni podaci o trenutnom vremenu!' } }
    end

    def weather_forecast_data(locale = :en)
      if locale == :bs
        weather_response = @conn.get('forecast', { lang: 'hr', units: 'metric' })
        weather_data = weather_response.body['list']
      else
        weather_response = @conn.get('forecast', { units: 'metric' })
        weather_data = weather_response.body['list']
      end

      today_forecast = []
      dates = {}
      weather_data.each do |e|
        key = I18n.localize(Time.at(e.dig('dt')&.to_i)&.getlocal('+01:00'), format: :short) # what if nil ? Time&.at(nil) still throws error ?
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
      [today_forecast, dates]
      
    rescue StandardError => _e
      { error: { en: 'Error: No weather forecast data available!', 
                 bs: 'Greška: Nedostupni podaci o vremenskoj prognozi!' } }
    end

    def utc_to_datetime(seconds)
      I18n.localize(Time.at(seconds.to_i).getlocal('+01:00'), format: :hm)
    end 

    def active_meteoalarms
      current_alarms_unsorted = Meteoalarm::Client.alarms('BA', area: 'Sarajevo', active_now: true)
      current_alarms = remove_duplicate_alarms(current_alarms_unsorted)

      current_alarms.each do |alarms|   
        alarms[:alert][:info] = alarms[:alert][:info].each_with_object({}) do |info, result|
          result[info[:language].to_sym] = info
        end
      end

      future_alarms_unsorted = Meteoalarm::Client.alarms('BA', area: 'Sarajevo', future_alarms: true)
      future_alarms = remove_duplicate_alarms(future_alarms_unsorted)

      future_alarms.each do |alarms|
        alarms[:start_date] = Time.parse(alarms[:alert][:info].first[:onset]).to_s
        alarms[:alert][:info] = alarms[:alert][:info].each_with_object({}) do |info, result|
          result[info[:language].to_sym] = info
        end
      end
      future_alarms.sort_by! {|element| element[:start_date]}
      [current_alarms, future_alarms]
    end

    def remove_duplicate_alarms(unsorted_alarms)
      grouped_alarms = unsorted_alarms.group_by{|alarm| alarm[:alert][:info][0][:parameter][1][:value]}

      grouped_alarms.each do |type, alarms|
        alarms.sort_by! {|element| element[:alert][:sent]}.reverse!
        grouped_alarms[type] = alarms.first
      end

      grouped_alarms.values
    end

    def yr_sarajevo
      ENV['TZ'] = 'Europe/Sarajevo'

      # Do not use more than 4 decimals to avoid blocking
      lat = 43.8519
      lon = 18.3866
      altitude = 520
      sitename = 'https://sarajevo-meteo.com/ https://github.com/em-jov/sa_weather_aqi'
      # locationforecastURL = "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=#{altitude}&lat=#{lat}&lon=#{lon}"

      conn = Faraday.new(
        url: 'https://api.met.no/weatherapi/locationforecast/2.0/complete.json',
        params: { altitude: altitude, lat: lat, lon: lon },
        headers: { 'Content-Type' => 'application/json', 'User-Agent' => sitename }) do |f|
        f.response :json
      end

      yr_response = conn.get()
      status = yr_response.status
      headers = yr_response.headers
      data = yr_response.body

      #pp data["properties"]["timeseries"][0]["time"]

      weather = {}
      data["properties"]["timeseries"].each do |ts|
        weather["time"] = Time.parse(data["properties"]["timeseries"][0]["time"])
      end

      # Assuming you have a UTC time, you can convert it to the local time zone
      utc_time = Time.parse(data["properties"]["timeseries"][0]["time"])
      local_time = utc_time.localtime

      # Output the local time
      # puts local_time

      pp data

    end
   
  end
end




