# frozen_script_literal: true
require 'erb'
require 'dotenv/load'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'time'

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
    latest_aqi_values = latest_aqi_values_by_monitoring_stations
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

  def latest_aqi_values_by_monitoring_stations
    stations = { 'Ilidža' => { latitude: 43.830 , longitude: 18.310 }, 
                 'Otoka' => { latitude: 43.848, longitude: 18.363 }, 
                 'Vijećnica' => { latitude: 43.859, longitude: 18.434 },
                 'US Embassy' => {} }

    ks_website = Nokogiri::HTML(URI.open('https://aqms.live/kvalitetzraka/index.php'))
    table = ks_website.css('table:first tbody tr')
    headers = table.first.css('td').map(&:content)
    table.each do |tr|
      name = tr.css('td').first.content
      next unless stations.keys.include?(name)

      headers.each_with_index do |header, index|
        next if ['Stanica', 'Mreža'].include?(header)
        content = tr.css('td')[index].content
        value = content.split(' ').first
        css_class = value == 'X' ? '' : pollutant_aqi_description(header, value)
        stations[name][header] = { content: content , class: css_class } 
      end
    end
    
    iqair_website = Nokogiri::HTML(URI.open('https://www.iqair.com/bosnia-herzegovina/federation-of-b-h/sarajevo/us-embassy-in-sarajevo'))
    pm2_5 = iqair_website.css('.pollutant-concentration-value').first.content
    time = Time.parse(iqair_website.css('time').first['datetime']).strftime('%d.%m.%Y. %Hh')
    stations['US Embassy']["PM2.5"] = { content: pm2_5 + ' ug/m3 ' + time, class: pollutant_aqi_description("pm2.5", pm2_5)}

    stations
  end

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
      a = a_data.find { |ad| ad["dt"] == w["dt"] }
      w["aqi"] = a.dig("main", "aqi") if a
    end

    dates = {}
    w_data.each do |e|
      key = Time.at(e["dt"].to_i).to_datetime.strftime("%d.%m.%Y.")
      interval = { aqi: e.dig("aqi"),
                   aqi_class: AQI.key(e.dig("aqi")),
                   description: e.dig("weather", 0, "description"),
                   icon: e.dig("weather", 0, "icon"),
                   temp: e.dig("main", "temp"),
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
      so2: { value: so2 , class: pollutant_aqi_description('so2', so2)},
      no2: { value: no2 , class: pollutant_aqi_description('no2', no2) },
      pm10: { value: pm10 , class: pollutant_aqi_description('pm10', pm10) },
      pm2_5: { value: pm2_5 , class: pollutant_aqi_description('pm2_5', pm2_5) },
      o3: { value: o3 , class: pollutant_aqi_description('o3', o3) },   
      co: { value: co , class: pollutant_aqi_description('co', co) }}
  end

  def current_data
    url = "https://api.openweathermap.org/data/2.5/weather?lat=#{LAT}&lon=#{LON}&units=metric&appid=#{ENV['API_KEY']}" 
    response_json = Faraday.get(url)
    response = JSON.parse(response_json.body)

    { currenttemp: response.dig("main", "temp").to_f.round,
      feelslike: response.dig("main", "feels_like").to_f.round,
      humidity: response.dig("main", "humidity"),
      description: response.dig("weather", 0, "description"),
      icon: response.dig("weather", 0, "icon"),
      rain: response.dig("rain, 1h") || 0,
      wind: response.dig("wind", "speed"),
      sunrise: utc_to_datetime(response.dig("sys", "sunrise")),
      sunset: utc_to_datetime(response.dig("sys","sunset")) }
  end

  def pollutant_aqi_description(pollutant, value)
    Kernel.const_get("WeatherAir::" + pollutant.upcase.gsub('.', '_')).select { |k,v| v.include?(value.to_f) }.keys.first.to_s
  end

  def utc_to_datetime(seconds)
    Time.at(seconds.to_i).to_datetime.strftime("%H:%M:%S")
  end
end

WeatherAir.new.run