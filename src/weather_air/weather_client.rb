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
  end
end