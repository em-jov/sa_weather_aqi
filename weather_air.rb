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
  AQI = { good: 0..50, moderate: 51..100, unhealthy_for_sensitive_groups: 101..150, unhealthy: 151..200, very_unhealthy: 201..300, hazardous: 301..500 }

  def run
    current_weather = current_weather_data
    pollutants = current_air_pollution
    latest_aqi_values = latest_pollutant_values_by_monitoring_stations
    weather_forecast = forecast
    
    cityAQI = current_air_pollution.values.map{ |v| v[:value]}.max
    cityAQIclass = AQI.select{|k, v| v.include?(cityAQI) }.keys.first.to_s

    template = ERB.new(File.read('template.html.erb'))
    result = template.result(binding)    
    File.write('index.html', result)
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
    monitoring_stations = { 'Vijećnica' => { latitude: 43.859, longitude: 18.434 },
                             'Bjelave'  => { latitude: 43.867, longitude: 18.420 },                         
                             'US Embassy' => { latitude: 43.856, longitude: 18.397 },
                             'Otoka' => { latitude: 43.848, longitude: 18.363 },
                             'Ilidža' => { latitude: 43.830 , longitude: 18.310 }}

    fhmzbih_website = Nokogiri::HTML(URI.open('https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php'))
    table = fhmzbih_website.css('table table').first

    embassy = table.css('tr')[2]
    bjelave = table.css('tr')[4]
    vijecnica = table.css('tr')[6]
    otoka = table.css('tr')[7]
    ilidza = table.css('tr')[8]

    monitoring_stations['Bjelave'].merge!(scrape_pollutant_aqi(bjelave))
    monitoring_stations['US Embassy'].merge!(scrape_pollutant_aqi(embassy))
    monitoring_stations['Vijećnica'].merge!(scrape_pollutant_aqi(vijecnica))
    monitoring_stations['Otoka'].merge!(scrape_pollutant_aqi(otoka))
    monitoring_stations['Ilidža'].merge!(scrape_pollutant_aqi(ilidza))

    monitoring_stations  
  end

  def scrape_pollutant_aqi (station)#, name)
    pollutants = { so2: station.css('td')[3]&.content,
                   no2: station.css('td')[5]&.content,
                   co: station.css('td')[7]&.content,
                   o3: station.css('td')[9]&.content,
                   pm10: station.css('td')[11]&.content,
                   pm2_5: station.css('td')[13]&.content }

   # save pollutant values as numbers ? fix template ? 
   # try to do it with greatest two values
   # pp pollutants.reject{ |k, v| k if  v == '' or v == nil or v == '*'}.sort_by {|_key, value| value}.to_h
   # pp pollutants.key(pollutants.values.max)

    pollutants.each do |k, v|
      pollutants[k] =  if v == '*' or v == "" or v.nil? or v == "0" # zero value should probably be checked differently
                        { value: '', class: '' }
                       else
                        { value: v.to_i, class: AQI.select { |k,z| z.include?(v.to_i) }.keys.first.to_s }
                       end
    end

    calculate_total_aqi_for_monitoring_station(pollutants)
  end

  def calculate_total_aqi_for_monitoring_station(pollutants)
    #  https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-metodologija.php
    #  A significant change compared to the American model is that in the case when two or more pollutants have measured 
    #  concentrations that correspond to the Unhealthy or Very Unhealthy index categories, the value of the index of the 
    #  measuring site is automatically transferred to the next category by 
    #   - adding 50 index numbers (in the case when two or more pollutants in the category "Unhealthy"), 
    #   - or 100 index numbers (in the case when two or more pollutants are in the category "Very unhealthy"). 
    #  In the case when the concentrations of two or more pollutants are within the "Hazardous" category, 
    #  a value of up to 100 index points is added, with the maximum total number of Index values ​​not exceeding 500. In this
    #  case, the Index category remains the same ("Hazardous").
    #  Index values ​​for each individual pollutant remain the same in these cases. 
    #  In this case, floating particles of different dimensions (PM10 and PM2.5) if they are measured side by side at the 
    #  same measuring point - are not treated as two pollutants.
    

    # if pollutant AQI is in the category "Good", "Moderate" or "Unhealthy for sensitive groups", 
    # total AQI for measuring site is just the highest pollutant AQI 
    msAQI = pollutants.values.reject{ |v| v[:value] == '' }.map{ |v| v[:value] }.max
    msAQIclass = AQI.select{ |k, v| v.include?(msAQI) }.keys.first.to_s
    pollutants[:aqi] = { value: msAQI || "", class: msAQIclass}

    unhealthy = pollutants.reject{ |k, v| k == :aqi }.count{|_, v| v[:class] == "unhealthy"} 
    very_unhealthy = pollutants.reject{ |k, v| k == :aqi }.count{|_, v| v[:class] == "very_unhealthy"}
    hazardous = pollutants.reject{ |k, v| k == :aqi }.count{|_, v| v[:class] == "hazardous"} 

    if pollutants[:pm10][:class] == "unhealthy" && (pollutants[:pm2_5][:class] == "unhealthy" || pollutants[:pm2_5][:class] == "very_unhealthy" or pollutants[:pm2_5][:class] == "hazardous")
      unhealthy =- 1 
    elsif pollutants[:pm10][:class] == "very_unhealthy" && pollutants[:pm2_5][:class] == "hazardous"
      very_unhealthy =- 1
    elsif pollutants[:pm10][:class] == "hazardous" && pollutants[:pm2_5][:class] == "hazardous" 
      hazardous =- 1
    end

    added_value = 0
    if hazardous >=2
      added_value = pollutants[:aqi][:value].to_i + 100
      if added_value > 500
        added_value = 500
      end
      pollutants[:aqi] = { value: added_value , class: AQI.select{ |k, v| v.include?(added_value) }.keys.first.to_s }
      return pollutants
    elsif very_unhealthy >=2 || very_unhealthy == 1 && hazardous >=1     
      added_value = pollutants[:aqi][:value].to_i + 100
      pollutants[:aqi] = { value: added_value , class: AQI.select{ |k, v| v.include?(added_value) }.keys.first.to_s }
      return pollutants
    elsif unhealthy >= 2 || unhealthy == 1 && (very_unhealthy >=1 || hazardous >=1) 
      added_value = pollutants[:aqi][:value].to_i + 50
      pollutants[:aqi] = { value: added_value , class: AQI.select{ |k, v| v.include?(added_value) }.keys.first.to_s }
      return pollutants
    end
 
    pollutants
  end

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

  def current_air_pollution  
    stations = latest_pollutant_values_by_monitoring_stations

    so2 = stations.values.map{ |v| (v[:so2][:value]=="" ? 0 : v[:so2][:value])}.max
    no2 = stations.values.map{ |v| (v[:no2][:value]=="" ? 0 : v[:no2][:value])}.max
    co = stations.values.map{ |v| (v[:co][:value]=="" ? 0 : v[:co][:value])}.max
    o3 = stations.values.map{ |v| (v[:o3][:value]=="" ? 0 : v[:o3][:value])}.max
    pm10 = stations.values.map{ |v| (v[:pm10][:value]=="" ? 0 : v[:pm10][:value])}.max
    pm2_5 = stations.values.map{ |v| (v[:pm2_5][:value]=="" ? 0 : v[:pm2_5][:value])}.max

    maxAQIs = {so2: { value: so2, class: AQI.select { |k,z| z.include?(so2) }.keys.first.to_s },
               no2: { value: no2, class: AQI.select { |k,z| z.include?(no2) }.keys.first.to_s } ,
               co: { value: co, class: AQI.select { |k,z| z.include?(co) }.keys.first.to_s } , 
               o3: { value: o3, class: AQI.select { |k,z| z.include?(o3) }.keys.first.to_s } , 
               pm10: { value: pm10, class: AQI.select { |k,z| z.include?(pm10) }.keys.first.to_s } , 
               pm2_5: { value: pm2_5, class: AQI.select { |k,z| z.include?(pm2_5) }.keys.first.to_s } }
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

  def utc_to_datetime(seconds)
    Time.at(seconds.to_i).to_datetime.strftime('%H:%M')
  end
end

WeatherAir.new.run