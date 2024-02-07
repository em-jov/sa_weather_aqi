module WeatherAir
  class AirQualityIndex
    # AQI range descriptors
    AQI = { good: 0..50, 
            moderate: 51..100,   
            unhealthy_for_sensitive_groups: 101..150, 
            unhealthy: 151..200, 
            very_unhealthy: 201..300, 
            hazardous: 301..500 }
    
    STATIONS = { 'vijecnica' => { name: 'Vijećnica' , latitude: 43.859, longitude: 18.434 },
                 'bjelave'  => { name: 'Bjelave' , latitude: 43.867, longitude: 18.420 },                         
                 'embassy' => { name: 'Ambasada SAD' , latitude: 43.856, longitude: 18.397 },
                 'otoka' => { name: 'Otoka', latitude: 43.848, longitude: 18.363 },
                 'ilidza' => { name: 'Ilidža', latitude: 43.830 , longitude: 18.310 },
                 'vogosca' => { name: 'Vogošća', latitude: 43.900, longitude: 18.342 },
                 'hadzici' => { name: 'Hadžići', latitude:43.823, longitude: 18.200 },
                 'ilijas' => { name: 'Ilijaš', latitude: 43.960, longitude: 18.269 },
                 'ivan_sedlo' => { name: 'Ivan sedlo', latitude: 43.750, longitude: 18.035 } }

    def stations_pollutants_aqi_data
      return @stations_pollutants_aqi_data if @stations_pollutants_aqi_data
      
      stations_tr_html = fetch_fhmzbih_data 
      stations = extract_pollutants_aqi_values_for_stations(stations_tr_html) 
      if stations['embassy'][:pm2_5].nil?
        stations['embassy'][:pm2_5] = us_embassy_pm2_5_aqicn
      end
      stations.each do |station, pollutants|
        pollutants[:aqi] = calculate_total_aqi(pollutants)
        pollutants[:e_pm2_5] = estimate_pm2_5(pollutants[:pm10], pollutants[:pm2_5])
        pollutants[:e_aqi] = calculate_total_aqi(pollutants)
        stations[station] = add_aqi_descriptor(pollutants).merge(STATIONS[station])
      end
      @stations_pollutants_aqi_data = stations
    end

    def city_pollutants_aqi
      city_pollutants = fetch_max_values(stations_pollutants_aqi_data)
                  
      city_pollutants[:e_aqi] = calculate_total_aqi(city_pollutants)
      city_pollutants[:aqi] = calculate_total_aqi(city_pollutants.reject{|k, _v| k==:e_pm2_5})

      add_aqi_descriptor(city_pollutants)
    end

    def aqi_by_ks(locale = :en)
      stations = { 'Vijećnica' => { name: 'vijecnica', latitude: 43.859, longitude: 18.434 },
                   'Otoka' => { name: 'otoka', latitude: 43.848, longitude: 18.363 },
                   'Ilidža' => { name: 'ilidza', latitude: 43.830 , longitude: 18.310 },
                   'Vogošća' => { name: 'vogosca', latitude: 43.900, longitude: 18.342 },
                   'Ilijaš' => { name: 'ilijas', latitude: 43.960, longitude: 18.269 }}

      stations.each do |station, values|
        values.merge!(fetch_pollutants_from_ks_website(values[:name], locale))
      end

      stations
    end

    def fetch_pollutants_from_ks_website(station, locale)
  
      station_ks_site = Nokogiri::HTML(URI.open("https://aqms.live/kvalitetzraka/st.php?st=#{station}"))
      table = station_ks_site.search(".table.table-hover").first

      table.elements[1].children.each do |el|
        el.children.each do |child|
          child.text if child.name == "th"
        end
      end

      pollutants = { "SO2" => {}, "NO2" => {}, "CO" => {}, "O3" => {}, "PM10" => {}, "PM2.5" => {} }

      table.elements[1].children.each do |el|
        next if el.children.first.nil? 
        key = /\(.*?\)/.match(el.children.first.text)[0].delete("()")
        if pollutants.has_key?(key)
          pollutants[key] = {
            date: I18n.localize(Time.parse(el.children[1].text), format: :normal),
            time: I18n.localize(Time.parse(el.children[1].text.split(' ')[1][0..1] + ":00"), format: :hm),
            display: Time.parse(el.children[1].text).to_date == Time.now.to_date,
            concentration: el.children[3].text,
            css_bg_color: el.children[5].attribute_nodes.first.value,
            aqi: el.children[5].text,
          }
        end
      end
      
      pollutants
    end

    private

    def fetch_fhmzbih_data
      fhmzbih_website = Nokogiri::HTML(URI.open('https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php'))
      
      # !!! hard-coded (table), potential problems if source HTML changes
      table = fhmzbih_website.css('table table').first

      # all of the pollutant values for one monitoring station are contained within one <tr> element
      # inside that <tr> element, within the first <td> element, the name of the station is specified
      # the station name is checked before collecting <tr> content to ensure reliable data extraction
      2.upto(10).each_with_object({}) do |index, stations_tr_html|
        row = table.css('tr')[index]
        stations_tr_html['embassy'] = row and next if row.css('td')[1].content.include?('Ambasada SAD')
        stations_tr_html['bjelave'] = row and next if row.css('td')[0].content.include?('Bjelave')
        stations_tr_html['vijecnica'] = row and next if row.css('td')[0].content.include?('Vijećnica')
        stations_tr_html['otoka'] = row and next if row.css('td')[0].content.include?('Otoka')
        stations_tr_html['ilidza'] = row and next if row.css('td')[0].content.include?('Ilidža')
        stations_tr_html['vogosca'] = row and next if row.css('td')[0].content.include?('Vogošća')
        stations_tr_html['hadzici'] = row and next if row.css('td')[0].content.include?('Hadžići')
        stations_tr_html['ivan_sedlo'] = row and next if row.css('td')[0].content.include?('IvanSedlo')
        stations_tr_html['ilijas'] = row and next if row.css('td')[1].content.include?('Ilijaš')
      end
    end

    def extract_pollutants_aqi_values_for_stations(stations_tr_html)
      STATIONS.each_with_object({}) do |(station, _value), monitoring_stations|
        monitoring_stations[station] = extract_pollutants_aqi_values(stations_tr_html[station], station)
      end
    end

    def extract_pollutants_aqi_values(station_tr_html, station_name)
      # !!! hard-coded (pollutants td indexes), potential problems if source HTML changes
      us_embassy_pm2_5_index = 9
      if station_name == 'embassy'
        return { so2: nil, no2: nil, co: nil, o3: nil, pm10: nil, pm2_5: normalize_pollutant_aqi_value(station_tr_html, us_embassy_pm2_5_index)}
      end

      if station_name == 'vogosca'
        return {
          so2: normalize_pollutant_aqi_value(station_tr_html, 3),
          no2: normalize_pollutant_aqi_value(station_tr_html, 5),
          co: nil,
          o3: nil,
          pm10: normalize_pollutant_aqi_value(station_tr_html, 9),
          pm2_5: normalize_pollutant_aqi_value(station_tr_html, 11)
        }
      end

      if station_name == 'ilijas'
        return {
          so2: normalize_pollutant_aqi_value(station_tr_html, 4),
          no2: normalize_pollutant_aqi_value(station_tr_html, 6),
          co: nil,
          o3: normalize_pollutant_aqi_value(station_tr_html, 9),
          pm10: normalize_pollutant_aqi_value(station_tr_html, 11),
          pm2_5: nil
        }
      end

      pollutant_td_index = { so2: 3, no2: 5, co: 7, o3: 9, pm10: 11, pm2_5: 13 }
      pollutant_td_index.each_with_object({}) do |(pollutant, index), result|
        result[pollutant] = normalize_pollutant_aqi_value(station_tr_html, index)
      end
    end

    def normalize_pollutant_aqi_value(station_tr_html, index)
      # when pollutant AQI is meassured, value is displayed as either "some_positive_number" or "0" 
      # when pollutant AQI is not meassured, value is shown an empty string ("") or nil or "*" or "0"  or &nbsp; (ASCII value - 0xa0)
      # to determine whether "0" represents an actual value or a lack of measurement, the preceding <td> needs to be checked 
      # if it contains "google_map/images/b.png" (green circle), it indicates an actual (and the best) value, otherwise, it does not
      return nil if station_tr_html.nil?
      scraped_data = station_tr_html.css('td')[index]&.content

      if scraped_data == "0"
        prior_td_field = station_tr_html.css('td')[index-1]&.css('img')&.first&.attributes&.values&.first&.value
        if prior_td_field == "google_map/images/b.png"
          return 0
        else
          return nil
        end
      end

      return nil if scraped_data == "*" || scraped_data&.empty? || scraped_data.nil? || scraped_data.ord == 0xa0

      scraped_data.to_i
    end

    # Computation of the AQI: 
    # https://en.wikipedia.org/w/index.php?title=Air_quality_index#Computing_the_AQI
    # - If multiple pollutants are measured at a monitoring site, 
    #   the highest or "dominant" AQI value is reported for the location.  
    #
    # A significant change compared to the American model: 
    # https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-metodologija.php 
    # - If two or more pollutants have concentrations in the "unhealthy" or "very unhealthy" categories, 
    #   the total index value of the measuring site increases to the next category:
    #     - for "unhealthy," it adds 50 index numbers, and 
    #     - for "very unhealthy," it adds 100.
    #
    # - If two or more pollutants are in the "hazardous" category, up to 100 index points are added, 
    #   but the category remains "hazardous" (the total index value doesn't go beyond 500).
    #
    # - Individual pollutant index values remain the same.
    #
    # - Floating particles of different sizes (PM10 and PM2.5) measured at the same point 
    #   are not treated as two separate pollutants.
    def calculate_total_aqi(pollutants)
      return nil if pollutants[:pm10].nil? && pollutants[:pm2_5].nil?

      # treating PM10 and PM2.5 as a single pollutant, using the higher of the two values (usually PM2.5) 
      # even if their AQI is better than "unhealthy," the total AQI for monitoring site always considers 
      # the highest AQI value among all pollutants
      if pollutants.has_key?(:e_pm2_5)
        pollutants[:pm] = [pollutants[:pm10], pollutants[:pm2_5], pollutants[:e_pm2_5]]&.compact&.max
        # to determine whether additional index numbers needs to be added, 
        # simply identify the two pollutants with the highest AQI values
        pollutants = pollutants.reject { |k,v| k if k == :pm10 || k== :pm2_5 || k== :e_pm2_5 || v.nil? || k==:aqi}
      else
        pollutants[:pm] = [pollutants[:pm10], pollutants[:pm2_5]]&.compact&.max
        pollutants = pollutants.reject { |k,v| k if k == :pm10 || k== :pm2_5 || v.nil? || k==:e_aqi}
      end

      pollutants = pollutants.values.sort { |a, b| b <=> a }.first(2)

      max_value = pollutants.max
      return max_value if max_value.nil? || pollutants.count == 1 # US embassy only measures pm2.5

      if pollutants.all? { |x| x >= AQI[:hazardous].first } #301
        max_value += 100
        if max_value > 500
          500
        else
          max_value
        end
      elsif pollutants.all? { |x| x >= AQI[:very_unhealthy].first } #201
        max_value += 100
      elsif pollutants.all? { |x| x >= AQI[:unhealthy].first } #101
        max_value += 50
      else
        max_value
      end
    end

    def add_aqi_descriptor(pollutants)
      pollutants.each do |k, v|
        (key, _values) =  AQI.select { |_x, y| y.include?(v) }.first
        pollutants[k] = { value: v, 
                          class: v.nil? ? '' : key.to_s }
      end
      pollutants
    end

    def fetch_max_values(stations_pollutants)
      stations_pollutants = stations_pollutants.reject { |k,v| !['Vijećnica', 'Bjelave', 'Ambasada SAD', 'Otoka'].include?(v[:name]) }

      pollutants = [:so2, :no2, :co, :o3, :pm10, :pm2_5, :e_pm2_5]
      pollutants.each_with_object({}) do |pollutant, result|
        result[pollutant] = stations_pollutants&.values&.map { |v| v&.dig(pollutant, :value) }&.compact&.max
      end
    end

    def estimate_pm2_5(pm10, pm2_5)
      return nil if (pm10.nil? && pm2_5.nil?)
      return pm2_5 unless pm2_5.nil?
      pm10c = WeatherAir::AqiCalculator.convert_pm10_aqi_to_concentration(pm10)
      pm25c = pm10c * 0.9
      #WeatherAir::AqiCalculator.convert_pm2_5_concentration_to_aqi(pm25c)
      WeatherAir::AqiCalculator.convert_concentration_to_aqi("pm25", pm25c)
    end

    def us_embassy_pm2_5_aqicn
      aqicn_website = Nokogiri::HTML(URI.open('https://aqicn.org/city/bosnia-herzegovina/sarajevo/us-embassy/'))
      pm2_5 = aqicn_website.css('.aqivalue').first.content.to_i
      time = Time.parse(aqicn_website.css('span#aqiwgtutime').first.content[11..]).strftime( "%d.%m.%Y. %H")
    
      pm2_5 = nil if time != Time.now.strftime( "%d.%m.%Y. %H")

      pm2_5
    end
  end
end