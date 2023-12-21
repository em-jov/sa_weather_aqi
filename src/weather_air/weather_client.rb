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

      weather_data.each_with_object({}) do |e, dates|
        key = I18n.localize(Time.at(e['dt'].to_i), format: :short)
        interval = { description: e.dig('weather', 0, 'description'),
                      icon: e.dig('weather', 0, 'icon'),
                      temp: e.dig('main', 'temp').to_f.round,
                      rain: e.dig('rain', '3h') || 0 }
        if dates.key?(key)
          dates[key] << interval 
        else
          dates[key] = [interval]
        end
      end
      
    rescue StandardError => _e
      { error: { en: 'Error: No weather forecast data available!', 
                 bs: 'Greška: Nedostupni podaci o vremenskoj prognozi!' } }
    end

    def utc_to_datetime(seconds)
      Time.at(seconds.to_i).to_datetime.strftime('%H:%M')
    end 
  end
end