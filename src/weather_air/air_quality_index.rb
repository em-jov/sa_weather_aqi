module WeatherAir
  class AirQualityIndex
    # AQI range descriptors
    AQI = { good: 0..50, 
            moderate: 51..100,   
            unhealthy_for_sensitive_groups: 101..150, 
            unhealthy: 151..200, 
            very_unhealthy: 201..300, 
            hazardous: 301..500 }

    EUAQI = { good_eea: 1,
              fair_eea: 2,
              moderate_eea: 3,
              poor_eea: 4,
              very_poor_eea: 5,
              extremely_poor_eea: 6 }
    
    STATIONS = { 'vijecnica' => { name: 'Vijećnica' , latitude: 43.859, longitude: 18.434 },
                 'bjelave'  => { name: 'Bjelave' , latitude: 43.867, longitude: 18.420 },                         
                 'otoka' => { name: 'Otoka', latitude: 43.848, longitude: 18.363 },
                 'ilidza' => { name: 'Ilidža', latitude: 43.830 , longitude: 18.310 },
                 'vogosca' => { name: 'Vogošća', latitude: 43.900, longitude: 18.342 },
                 'hadzici' => { name: 'Hadžići', latitude:43.823, longitude: 18.200 },
                 'ilijas' => { name: 'Ilijaš', latitude: 43.960, longitude: 18.269 },
                 'ivan_sedlo' => { name: 'Ivan sedlo', latitude: 43.750, longitude: 18.035 } }

    def aqi_by_fhmz
      return @aqi_by_fhmz if @aqi_by_fhmz
      
      stations_tr_html = fetch_fhmzbih_data
      stations = extract_pollutants_aqi_values_for_stations(stations_tr_html)

      stations.each do |station, pollutants|
        stations[station] = pollutants.merge(STATIONS[station])
      end

      stations.each do |station, pollutants|
        if pollutants[:aqi][:value].empty?
          stations.delete(station)
        end
      end
      raise 'No fhmzbih data.' if stations == {}

      @aqi_by_fhmz = stations      
    rescue StandardError => exception
      ExceptionNotifier.notify(exception)  
      { error: { en: 'Error: No current air quality index data available from Federal Hydro-Meteorological Institute! Please visit <a href="https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php">fhmzbih.gov.ba</a> for more information.', 
                 bs: 'Greška: Nedostupni podaci o indeksu kvalitete zraka Federalnog hidrometeoroloskog zavoda! Posjetite <a href="https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php">fhmzbih.gov.ba</a> za više informacija.' } }  
    end

    def aqi_by_ks
      stations = { 'Vijećnica' => { name: 'vijecnica', latitude: 43.859, longitude: 18.434 },
                   'Otoka' => { name: 'otoka', latitude: 43.848, longitude: 18.363 },
                   'Ilidža' => { name: 'ilidza', latitude: 43.830 , longitude: 18.310 },
                   'Vogošća' => { name: 'vogosca', latitude: 43.900, longitude: 18.342 },
                   'Ilijaš' => { name: 'ilijas', latitude: 43.960, longitude: 18.269 }}

      stations.each do |station, values|
        values.merge!(fetch_pollutants_from_ks_website(values[:name]))
      end

      stations
    end

    def aqi_by_ekoakcija
      station_ea_site = Nokogiri::HTML(URI.open("https://zrak.ekoakcija.org/sarajevo"))
      table = station_ea_site.search(".views-table.cols-6 tbody tr")

      ea_table = []
      table.each do |tr|
        ea_table << tr.search('td').each_with_object([]) do |td, n|
          n << td.text.strip 
        end
      end
      aqi_values = []
      ea_table.each do |x|
        aqi_values << x[4].to_i
      end
      city_aqi_value =  aqi_values.max
      city_aqi_desc = AQI.find{|key, value| value.include?(city_aqi_value)}.first.to_s
      [ea_table, city_aqi_value, city_aqi_desc]
    rescue StandardError => exception
      ExceptionNotifier.notify(exception)  
      { error: { en: 'Error: No current data available from zrak.ekoakcija.org.', 
                 bs: 'Greška: Nedostupni podaci sa stranice zrak.ekoakcija.org.' } }  
    end

    def citywide_aqi_by_fhmz
      citywide_aqi = fetch_max_values(aqi_by_fhmz)

      citywide_aqi[:value] = citywide_aqi.max_by{|k,v| v}[1]
      citywide_aqi[:class] = EUAQI.key(citywide_aqi[:value])

      citywide_aqi
    end

    private

    def fetch_pollutants_from_ks_website(station)
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
            date: Time.parse(el.children[1].text),
            time: Time.parse(el.children[1].text.split(' ')[1][0..1] + ":00"),
            display: Time.parse(el.children[1].text).to_date == Time.now.to_date,
            concentration: el.children[3].text,
            css_class: bg_color_to_class(el.children[5].attribute_nodes.first.value[18..24]),
            aqi: el.children[5].text,
          }
        end
      end
      
      pollutants
    end

    def bg_color_to_class(bg_color)
      case bg_color
      when "#00FF00"
        "good"
      when "#FFFF00"
        "moderate"
      when "#FFA500"
        "unhealthy_for_sensitive_groups"
      when "#FF0000"
        "unhealthy"
      when "#800080"
        "very_unhealthy"
      when "#800000"
        "hazardous"
      end
    end

    def fetch_fhmzbih_data
      fhmzbih_website = Nokogiri::HTML(URI.open('https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php'))
      
      # !!! hard-coded (table), potential problems if source HTML changes
      table = fhmzbih_website&.css('table table').first
      
      # all of the pollutant values for one monitoring station are contained within one <tr> element
      # inside that <tr> element, within the first <td> element, the name of the station is specified
      # the station name is checked before collecting <tr> content to ensure reliable data extraction
      2.upto(10).each_with_object({}) do |index, stations_tr_html|
        row = table&.css('tr')[index] 
        stations_tr_html['bjelave'] = row and next if row.css('td')[0].content.include?('Bjelave')
        stations_tr_html['vijecnica'] = row and next if row.css('td')[0].content.include?('Vijećnica')
        stations_tr_html['otoka'] = row and next if row.css('td')[0].content.include?('Otoka')
        stations_tr_html['ilidza'] = row and next if row.css('td')[0].content.include?('Ilidža')
        stations_tr_html['vogosca'] = row and next if row.css('td')[1].content.include?('Vogošća')
        stations_tr_html['hadzici'] = row and next if row.css('td')[0].content.include?('Hadžići')
        stations_tr_html['ivan_sedlo'] = row and next if row.css('td')[0].content.include?('IvanSedlo')
        stations_tr_html['ilijas'] = row and next if row.css('td')[1].content.include?('Ilijaš')
      end
    end

    def fetch_max_values(stations_pollutants)
      stations_pollutants = stations_pollutants.reject { |k,v| !['Vijećnica', 'Bjelave', 'Otoka'].include?(v[:name]) }

      pollutants = [:so2, :no2, :o3, :pm10, :pm25]
      pollutants.each_with_object({}) do |pollutant, result|
        result[pollutant] = stations_pollutants&.values&.map { |v| v&.dig(pollutant, :value) }&.compact&.max.to_i
      end
    end

    def extract_pollutants_aqi_values_for_stations(stations_tr_html)
      STATIONS.each_with_object({}) do |(station, _value), monitoring_stations|
        monitoring_stations[station] = eea_index(stations_tr_html[station], station)
      end
    end

    def eea_index(station_tr_html, station_name)
      pollutants = {aqi: {}, so2: {}, no2: {}, o3: {}, pm10: {}, pm25: {}}
      if station_name == 'vogosca' 
        pollutants[:aqi][:value] = station_tr_html.css('td')[2].content
        pollutants[:so2][:value] = station_tr_html.css('td')[3].content
        pollutants[:no2][:value] = station_tr_html.css('td')[5].content
        pollutants[:o3][:value] = station_tr_html.css('td')[7].content
        pollutants[:pm10][:value] = station_tr_html.css('td')[8].content
        pollutants[:pm25][:value] = station_tr_html.css('td')[10].content
      elsif station_name == 'ilijas'
        pollutants[:aqi][:value] = station_tr_html.css('td')[2].content
        pollutants[:so2][:value] = station_tr_html.css('td')[3].content
        pollutants[:no2][:value] = station_tr_html.css('td')[5].content
        pollutants[:o3][:value] = station_tr_html.css('td')[7].content
        pollutants[:pm10][:value] = station_tr_html.css('td')[9].content
        pollutants[:pm25][:value] = station_tr_html.css('td')[11].content
      else
        pollutants[:aqi][:value] = station_tr_html.css('td')[1].content
        pollutants[:so2][:value] = station_tr_html.css('td')[2].content
        pollutants[:no2][:value] = station_tr_html.css('td')[4].content
        pollutants[:o3][:value] = station_tr_html.css('td')[6].content
        pollutants[:pm10][:value] = station_tr_html.css('td')[8].content
        pollutants[:pm25][:value] = station_tr_html.css('td')[10].content
      end
      pollutants.each do |key, value|
        pollutants[key][:class] = EUAQI.key(value[:value].to_i)
      end
      pollutants
    end

  end
end