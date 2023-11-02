# frozen_script_literal: true
require 'erb'
require 'dotenv/load'
require 'faraday'

class WeatherAir
  LAT = 43.8519774
  LON = 18.3866868
  def run
    current_weather = current_data
    template = ERB.new(File.read('template.html.erb'))
    result = template.result(binding)
    File.write('index.html', result)
  end

  def current_data
    url = "https://api.openweathermap.org/data/2.5/weather?lat=#{LAT}&lon=#{LON}&units=metric&appid=#{ENV['API_KEY']}"
    response_json = Faraday.get(url)
    response = JSON.parse(response_json.body)

    { currenttemp: response["main"]["temp"].to_f.round,
      feelslike: response["main"]["feels_like"].to_f.round,
      humidity: response["main"]["humidity"],
      description: response["weather"][0]["description"],
      icon: response["weather"][0]["icon"],
      rain: response.dig("rain, 1h") || 0,
      wind: response["wind"]["speed"],
      sunrise: utc_to_datetime(response["sys"]["sunrise"]),
      sunset: utc_to_datetime(response["sys"]["sunset"]) }
  end

  def last_update 
    Time.now.getlocal('+01:00').to_s
  end

  def utc_to_datetime(seconds)
    Time.at(seconds.to_i).to_datetime.strftime('%H:%M:%S')
  end
end

WeatherAir.new.run

