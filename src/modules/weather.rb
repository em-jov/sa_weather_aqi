module Weather
  # Sarajevo coordinates
  LAT = 43.8519774
  LON = 18.3866868

  def forecast 
    conn = openweathermap_client

    weather_response = conn.get('forecast', { units: 'metric' })
    weather_data = weather_response.body['list']

    dates = {}
    weather_data.each do |e|
      key = Time.at(e['dt'].to_i).to_datetime.strftime('%a %d.%m.')
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
    dates
  end
  
  def current_weather_data
    conn = openweathermap_client

    weather_response = conn.get('weather', { units: 'metric' })
    data = weather_response.body

    { currenttemp: data.dig('main', 'temp').to_f.round,
      feelslike: data.dig('main', 'feels_like').to_f.round,
      humidity: data.dig('main', 'humidity'),
      description: data.dig('weather', 0, 'description'),
      icon: data.dig('weather', 0, 'icon'),
      rain: data.dig('rain', '1h') || 0,
      wind: data.dig('wind', 'speed'),
      sunrise: utc_to_datetime(data.dig('sys', 'sunrise')),
      sunset: utc_to_datetime(data.dig('sys','sunset')) }
  end

  def openweathermap_client
    Faraday.new( url: 'https://api.openweathermap.org/data/2.5/',
                  params: { lat: LAT, lon: LON, appid: ENV['API_KEY'] },
                  headers: { 'Content-Type' => 'application/json' }) do |f|
                  f.response :json
    end
  end

  def utc_to_datetime(seconds)
    Time.at(seconds.to_i).to_datetime.strftime('%H:%M')
  end 
end