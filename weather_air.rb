# frozen_script_literal: true
require 'erb'
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
  AQI = { good: 0..50, 
          moderate: 51..100, 
          unhealthy_for_sensitive_groups: 101..150, 
          unhealthy: 151..200, 
          very_unhealthy: 201..300, 
          hazardous: 301..500 }

  def run
    current_weather = current_weather_data

    pollutants = current_air_pollution_for_city
    cityAQI = pollutants[:aqi][:value]
    cityAQIclass =  pollutants[:aqi][:class]

    latest_aqi_values = latest_pollutant_values_by_monitoring_stations

    weather_forecast = forecast

    template = ERB.new(File.read('template.html.erb'))
    result = template.result(binding) 
    if ENV['DEVELOPMENT']   
      File.write('index.html', result)
    else 
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

    # hard-coded, potential problems if source table changes
    embassy = table.css('tr')[2]
    bjelave = table.css('tr')[4]
    vijecnica = table.css('tr')[6]
    otoka = table.css('tr')[7]
    ilidza = table.css('tr')[8]
    # ------------------------------------------------------ 

    monitoring_stations['Bjelave'].merge!(scrape_pollutant_aqi(bjelave))
    monitoring_stations['US Embassy'].merge!(scrape_pollutant_aqi(embassy))
    monitoring_stations['Vijećnica'].merge!(scrape_pollutant_aqi(vijecnica))
    monitoring_stations['Otoka'].merge!(scrape_pollutant_aqi(otoka))
    monitoring_stations['Ilidža'].merge!(scrape_pollutant_aqi(ilidza))

    monitoring_stations  
  end

  def scrape_pollutant_aqi(station)
    # hard-coded, potential problems if source table changes
    pollutant_td_index = { so2: 3, no2: 5, co: 7, o3: 9, pm10: 11, pm2_5: 13}
    pollutants = { so2: normalize_pollutant_value(station, pollutant_td_index[:so2]),
                   no2: normalize_pollutant_value(station, pollutant_td_index[:no2]),
                   co: normalize_pollutant_value(station, pollutant_td_index[:co]),
                   o3: normalize_pollutant_value(station, pollutant_td_index[:o3]),
                   pm10: normalize_pollutant_value(station, pollutant_td_index[:pm10]),
                   pm2_5: normalize_pollutant_value(station, pollutant_td_index[:pm2_5]) }
    # ------------------------------------------------------ 

    pollutants[:aqi] = calculate_total_aqi(pollutants)
    add_aqi_descriptor(pollutants)
  end

  def normalize_pollutant_value(station, index)
    # hard-coded, potential problems if source table changes
    # when pollutant AQI is not meassured, value is shown as "" or nil or "*" or "0"
    # when pollutant AQI is meassured, value is shown as "some_number" or "0" 
    # in order to know wether "0" represents actual value or lack of measurement, previous table's 'td' has to be checked, 
    # if it contains "google_map/images/b.png" (green circle) it is an actual value, otherwise it's not
    scraped_data = station.css('td')[index]&.content

    if scraped_data == "0"
      prior_td_field = station.css('td')[index-1]&.css('img')&.first&.attributes&.values&.first&.value
      if prior_td_field == "google_map/images/b.png"
        return 0
      else
        return nil
      end
    end

    scraped_data = if scraped_data == "*" or scraped_data&.empty? or scraped_data.nil? 
                      nil
                    else
                      scraped_data.to_i
                    end
  end

  def calculate_total_aqi(pollutants)
    # https://en.wikipedia.org/w/index.php?title=Air_quality_index#Computing_the_AQI
    # If multiple pollutants are measured at a monitoring site, 
    # then the largest or "dominant" AQI value is reported for the location.

    # https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-metodologija.php  
    # A significant change compared to the American model is that in the case when two or more pollutants have measured 
    # concentrations that correspond to the "unhealthy" or "very unhealthy" index categories, the value of the index of 
    # the measuring site is automatically transferred to the next category by adding 50 index numbers (in the case when two 
    # or more pollutants in the category "unhealthy"), or 100 index numbers (in the case when two or more pollutants are 
    # in the category "very unhealthy"). In the case when the concentrations of two or more pollutants are within the 
    # "hazardous" category, a value of up to 100 index points is added, with the maximum total number of Index values 
    # ​​not exceeding 500. In this case, the Index category remains the same ("hazardous").
    # Index values ​​for each individual pollutant remain the same in these cases. In this case, floating particles of 
    # different dimensions (PM10 and PM2.5) if they are measured side by side at the same measuring point - are not 
    # treated as two pollutants.
    # ------------------------------------------------------------------------------------------------------------------

    # replacing pm10 and pm2.5 with the highest value of the two, 
    # if their AQI is "unhealthy" or worse, total AQI will only take the highest value of the two for calculation
    # if it's not, total AQI just takes the highest AQI value from all pollutants anyway 
    pollutants[:pm] = [pollutants[:pm10], pollutants[:pm2_5]].compact.max
    #  ---------------------------------------------------------------------

    # getting two max pollutants AQI values
    pollutants = pollutants.reject{|k,v| k if k == :pm10 or k== :pm2_5 or v.nil? }
    pollutants = pollutants.sort_by {|_key, value| -value}.first(2).to_h.values
    #  ---------------------------------------------------------------------

    max_value = pollutants.max
    return max_value if max_value.nil?

    if pollutants.all?{ |x| x >= AQI[:hazardous].first } #301
    # In the case when the concentrations of two or more pollutants are within the "hazardous" category, 
    # a value of up to 100 index points is added, with the maximum total number of Index values ​​not exceeding 500.
      max_value += 100
      if max_value > 500
        return 500
      else
        return max_value
      end
    elsif pollutants.all?{ |x| x >= AQI[:very_unhealthy].first } #201
    # 100 index numbers (in the case when two or more pollutants are in the category "very unhealthy")
      return max_value += 100
    elsif pollutants.all?{ |x| x >= AQI[:unhealthy].first } #101
    # adding 50 index numbers (in the case when two or more pollutants in the category "unhealthy")
      return max_value += 50
    else
      return max_value
    end

  end

  def add_aqi_descriptor(pollutants)
    pollutants.each do |k, v|
      pollutants[k] = { value: v, class: v.nil? ? '' : AQI.select { |_x, y| y.include?(v) }.keys.first.to_s }
    end
    pollutants
  end

  def current_air_pollution_for_city  
    pollutants = latest_pollutant_values_by_monitoring_stations

    city_pollutants = { so2: pollutants.values.map{ |v| v[:so2][:value] }.compact.max,
                        no2: pollutants.values.map{ |v| v[:no2][:value] }.compact.max,
                        co: pollutants.values.map{ |v| v[:co][:value] }.compact.max,
                        o3: pollutants.values.map{ |v| v[:o3][:value] }.compact.max,
                        pm10: pollutants.values.map{ |v| v[:pm10][:value] }.compact.max,
                        pm2_5: pollutants.values.map{ |v| v[:pm2_5][:value] }.compact.max }

    city_pollutants[:aqi] = calculate_total_aqi(city_pollutants)
    add_aqi_descriptor(city_pollutants)
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

