# frozen_script_literal: true
require 'erb'
require 'dotenv/load'
require 'faraday'

class WeatherAir
  LAT = 43.8519774
  LON = 18.3866868

  AQI = { good: 1, fair: 2, moderate: 3, poor: 4, very_poor: 5 }
  SO2 = { good: 0...20, fair: 20...80, moderate: 80...250, poor: 250...350, very_poor: 350..1000 }
  NO2 = { good: 0...40, fair: 40...70, moderate: 70...150, poor: 150...200, very_poor: 200..1000 }
  PM10 = { good: 0...20, fair: 20...50, moderate: 50...100, poor: 100...200, very_poor: 200..1000 }
  PM2_5 = { good: 0...10, fair: 10...25, moderate: 25...50, poor: 50...75, very_poor: 75..1000 }
  O3 = { good: 0...60, fair: 60...100, moderate: 100...140, poor: 140...180, very_poor: 180..1000 }
  CO = { good: 0...4400, fair: 4400...9400, moderate: 9400...12400, poor: 12400...15400, very_poor: 15400..100000 }

  def run
    weather_forecast = forecast
    pollutants = air_pollution
    current_weather = current_data
    template = ERB.new(File.read('template.html.erb'))
    result = template.result(binding)
    File.write('index.html', result)
  end

  def last_update 
    Time.now.getlocal('+01:00').to_s
  end

  private

  def forecast 
    w_url = "https://api.openweathermap.org/data/2.5/forecast?lat=#{LAT}&lon=#{LON}&units=metric&appid=#{ENV['API_KEY']}" 
    w_response_json = Faraday.get(w_url)
    w_response = JSON.parse(w_response_json.body)
    w_data = w_response["list"]

    a_url = "https://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=#{LAT}&lon=#{LON}&units=metric&appid=#{ENV['API_KEY']}" 
    a_response_json = Faraday.get(a_url)
    a_response = JSON.parse(a_response_json.body)
    a_data = a_response["list"]

    w_data.each do |w|
      a = a_data.find { |ad| ad['dt'] == w['dt'] }
      w['aqi'] = a.dig('main', "aqi") if a
    end

    dates = {}
    w_data.each do |e|
      key = Time.at(e["dt"].to_i).to_datetime.strftime('%d.%m.%Y.')
      interval = { aqi: e["aqi"],
                   aqi_class: AQI.key(e["aqi"]),
                   description: e["weather"][0]["description"] ,
                   icon: e["weather"][0]["icon"] ,
                   temp: e["main"]["temp"],
                   rain: e.dig("rain","3h") || 0 }
      if dates.key?(key)
        dates[key] << interval 
      else
        dates[key] = [interval]
      end
    end
    dates
  end

  def air_pollution
    url = "https://api.openweathermap.org/data/2.5/air_pollution?lat=#{LAT}&lon=#{LON}&appid=#{ENV['API_KEY']}" 
    response = Faraday.get(url)
    return nil if response.status != 200

    data = JSON.parse(response.body)

    aqi = data&.dig("list", 0, "main", "aqi") 
    so2 = data&.dig("list", 0, "components", "so2") 
    no2 = data&.dig("list", 0, "components", "no2") 
    pm10 = data&.dig("list", 0, "components", "pm10") 
    pm2_5 = data&.dig("list", 0, "components", "pm2_5") 
    o3 = data&.dig("list", 0, "components", "o3") 
    co = data&.dig("list", 0, "components", "co") 

    { aqi: { value: aqi, class: AQI.key(aqi)},
      so2: { value: so2 , class: SO2.select { |k,v| v.include?(so2) }.keys.first.to_s },
      no2: { value: no2 , class: NO2.select { |k,v| v.include?(no2) }.keys.first.to_s },
      pm10: { value: pm10 , class: PM10.select { |k,v| v.include?(pm10) }.keys.first.to_s },
      pm2_5: { value: pm2_5 , class: PM2_5.select { |k,v| v.include?(pm2_5) }.keys.first.to_s },
      o3: { value: o3 , class: O3.select { |k,v| v.include?(o3) }.keys.first.to_s },   
      co: { value: co , class: CO.select { |k,v| v.include?(co) }.keys.first.to_s }}
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

  def utc_to_datetime(seconds)
    Time.at(seconds.to_i).to_datetime.strftime('%H:%M:%S')
  end
end

WeatherAir.new.run

