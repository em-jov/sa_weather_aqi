# frozen_script_literal: true
require 'erb'
require 'dotenv/load'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'time'
require 'aws-sdk-s3'
require 'aws-sdk-cloudfront'

class WeatherAir
  # Sarajevo coordinates
  LAT = 43.8519774
  LON = 18.3866868

  # AQI range descriptors
  AQI = { good: 1, fair: 2, moderate: 3, poor: 4, very_poor: 5 }
  SO2 = { good: 0...20, fair: 20...80, moderate: 80...250, poor: 250...350, very_poor: 350..1000 }
  NO2 = { good: 0...40, fair: 40...70, moderate: 70...150, poor: 150...200, very_poor: 200..1000 }
  PM10 = { good: 0...20, fair: 20...50, moderate: 50...100, poor: 100...200, very_poor: 200..1000 }
  PM2_5 = { good: 0...10, fair: 10...25, moderate: 25...50, poor: 50...75, very_poor: 75..1000 }
  O3 = { good: 0...60, fair: 60...100, moderate: 100...140, poor: 140...180, very_poor: 180..1000 }
  CO = { good: 0...4400, fair: 4400...9400, moderate: 9400...12400, poor: 12400...15400, very_poor: 15400..100000 }

  def run
    latest_aqi_values = latest_pollutant_values_by_monitoring_stations
    weather_forecast = forecast
    pollutants = current_air_pollution
    current_weather = current_weather_data

    template = ERB.new(File.read('template.html.erb'))
    result = template.result(binding)
    # File.write('index.html', result)
    s3_object = Aws::S3::Object.new(ENV['BUCKET'], 'index.html')
    s3_object.put({ body: result, content_type: 'text/html' })
    cloudfront_client = Aws::CloudFront::Client.new
    cloudfront_client.create_invalidation({
      distribution_id: ENV['CLOUDFRONT_DISTRIBUTION'],
      invalidation_batch: { 
        paths: { 
          quantity: 1, 
          items: ["/"],
        },
        caller_reference: Time.now.to_s
      }
    })
  end

  def last_update 
    Time.now.getlocal('+01:00').to_s
  end

  private

  def latest_pollutant_values_by_monitoring_stations
    stations = { 'Vijećnica' => { latitude: 43.859, longitude: 18.434 },
                 'Otoka' => { latitude: 43.848, longitude: 18.363 },
                 'US Embassy' => { latitude: 43.856, longitude: 18.397 },
                 'Ilidža' => { latitude: 43.830 , longitude: 18.310 }}

    # scraping data for 3 monitoring stations: Vijećnica, Otoka, Ilidža
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
    
    # scraping data for US Embassy monitoring station (only pm2.5)
    iqair_website = Nokogiri::HTML(URI.open('https://www.iqair.com/bosnia-herzegovina/federation-of-b-h/sarajevo/us-embassy-in-sarajevo'))
    pm2_5 = iqair_website.css('.pollutant-concentration-value').first.content
    time = Time.parse(iqair_website.css('time').first['datetime']).strftime('%d.%m.%Y. %Hh')
    stations['US Embassy']['PM2.5'] = { content: pm2_5 + ' ug/m3 ' + time, class: pollutant_aqi_description('pm2.5', pm2_5)}

    stations
  end

  def forecast 
    conn = openweathermap_client

    weather_response = conn.get('forecast', { units: 'metric' })
    weather_data = weather_response.body['list']

    aqi_response = conn.get('air_pollution/forecast', { units: 'metric' })
    aqi_data = aqi_response.body['list']

    # adding aqi to weather data
    weather_data.each do |w|
      a = aqi_data.find { |ad| ad['dt'] == w['dt'] }
      w['aqi'] = a.dig('main', 'aqi') if a
    end

    # creating 5 days forecast with 3 hours intervals 
    dates = {}
    weather_data.each do |e|
      key = Time.at(e['dt'].to_i).to_datetime.strftime('%d.%m.%Y.')
      interval = { aqi: e.dig('aqi'),
                   aqi_class: AQI.key(e.dig('aqi')),
                   description: e.dig('weather', 0, 'description'),
                   icon: e.dig('weather', 0, 'icon'),
                   temp: e.dig('main', 'temp'),
                   rain: e.dig('rain', '3h') || 0 }
      if dates.key?(key)
        dates[key] << interval 
      else
        dates[key] = [interval]
      end
    end
    dates
  end

  def current_air_pollution
    conn = openweathermap_client

    aqi_response = conn.get('air_pollution')
    data = aqi_response.body['list'][0]

    return nil if aqi_response.status != 200

    aqi = data&.dig('main', 'aqi') 
    so2 = data&.dig('components', 'so2') 
    no2 = data&.dig('components', 'no2') 
    pm10 = data&.dig('components', 'pm10') 
    pm2_5 = data&.dig('components', 'pm2_5') 
    o3 = data&.dig('components', 'o3') 
    co = data&.dig('components', 'co') 

    { aqi: { value: aqi, class: AQI.key(aqi)},
      so2: { value: so2 , class: pollutant_aqi_description('so2', so2)},
      no2: { value: no2 , class: pollutant_aqi_description('no2', no2) },
      pm10: { value: pm10 , class: pollutant_aqi_description('pm10', pm10) },
      pm2_5: { value: pm2_5 , class: pollutant_aqi_description('pm2_5', pm2_5) },
      o3: { value: o3 , class: pollutant_aqi_description('o3', o3) },   
      co: { value: co , class: pollutant_aqi_description('co', co) }}
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
                 params: { lat: "#{ LAT }", lon: "#{ LON }", appid: "#{ ENV['API_KEY'] }" },
                 headers: { 'Content-Type' => 'application/json' }) do |f|
                 f.response :json
    end
  end

  def pollutant_aqi_description(pollutant, value)
    Kernel.const_get('WeatherAir::' + pollutant.upcase.gsub('.', '_')).select { |k,v| v.include?(value.to_f) }.keys.first.to_s
  end

  def utc_to_datetime(seconds)
    Time.at(seconds.to_i).to_datetime.strftime('%H:%M:%S')
  end
end

WeatherAir.new.run