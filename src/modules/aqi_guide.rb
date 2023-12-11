module AqiGuide
  # AQI range descriptors
  AQI = { good: { value: 0..50, 
  who: "", 
  advisory: "It’s a great day to be active outside." }, 
  moderate: { value: 51..100, 
      who: "Some people who may be unusually sensitive to particle pollution.", 
      advisory: "<b>Unusually sensitive people</b>: Consider making outdoor activities shorter and less intense.
      Watch for symptoms such as coughing or shortness of breath. These are signs to take it easier. 
      <br><br> 
      <b>Everyone else</b>: It’s a good day to be active outside." },   
  unhealthy_for_sensitive_groups: { value: 101..150, 
                              who: "Sensitive groups include <b>people with heart or lung disease, older
                              adults, children and teenagers, minority populations, and outdoor workers.</b>", 
                              advisory: "<b>Sensitive groups</b>: Make outdoor activities shorter and less
                              intense. It’s OK to be active outdoors, but take more
                              breaks. Watch for symptoms such as coughing or
                              shortness of breath.
                              <br><br> 
                              <b>People with asthma</b>: Follow your asthma action plan and
                              keep quick relief medicine handy.
                              <br><br> 
                              <b>People with heart disease</b>: Symptoms such as
                              palpitations, shortness of breath, or unusual fatigue may
                              indicate a serious problem. If you have any of these,
                              contact your health care provider."}, 
  unhealthy: { value: 151..200, 
      who: "Everyone", 
      advisory: "<b>Sensitive groups</b>: Avoid long or intense outdoor activities.
      Consider rescheduling or moving activities indoors.
      <br><br>
      <b>Everyone else</b>: Reduce long or intense activities. Take
      more breaks during outdoor activities."}, 
  very_unhealthy: { value: 201..300, 
              who: "Everyone", 
              advisory: "<b>Sensitive groups</b>: Avoid all physical activity outdoors.
              Reschedule to a time when air quality is better or move
              activities indoors.
              <br><br>
              <b>Everyone else</b>: Avoid long or intense activities. Consider
              rescheduling or moving activities indoors."}, 
  hazardous: { value: 301..500, 
      who: "Everyone", 
      advisory: "<b>Everyone</b>: Avoid all physical activity outdoors.
      <br><br>
      <b>Sensitive groups</b>: Remain indoors and keep activity levels
      low. Follow tips for keeping particle levels low indoors."} }


  def latest_pollutant_values_by_monitoring_stations
    monitoring_stations = { 'Vijećnica' => { latitude: 43.859, longitude: 18.434 },
                            'Bjelave'  => { latitude: 43.867, longitude: 18.420 },                         
                            'US Embassy' => { latitude: 43.856, longitude: 18.397 },
                            'Otoka' => { latitude: 43.848, longitude: 18.363 },
                            'Ilidža' => { latitude: 43.830 , longitude: 18.310 } }

    fhmzbih_website = Nokogiri::HTML(URI.open('https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php'))
    table = fhmzbih_website.css('table table').first

    # hard-coded, potential problems if source table changes
    embassy = bjelave = vijecnica = otoka = ilidza = nil
    2.upto(10).each do |index|
      row = table.css('tr')[index]
      embassy = row and next if row.css('td')[1].content.include?("Ambasada SAD")
      bjelave = row and next if row.css('td')[0].content.include?("Bjelave")
      vijecnica = row and next if row.css('td')[0].content.include?("Vijećnica")
      otoka = row and next if row.css('td')[0].content.include?("Otoka")
      ilidza = row and next if row.css('td')[0].content.include?("Ilidža")
    end

    monitoring_stations['Bjelave'].merge!(scrape_pollutant_aqi(bjelave))
    monitoring_stations['US Embassy'].merge!(scrape_pollutant_aqi(embassy))
    monitoring_stations['Vijećnica'].merge!(scrape_pollutant_aqi(vijecnica))
    monitoring_stations['Otoka'].merge!(scrape_pollutant_aqi(otoka))
    monitoring_stations['Ilidža'].merge!(scrape_pollutant_aqi(ilidza))

    monitoring_stations  
  end

  def scrape_pollutant_aqi(station)
    # hard-coded, potential problems if source table changes
    pollutant_td_index = { so2: 3, no2: 5, co: 7, o3: 9, pm10: 11, pm2_5: 13 }
    pollutants = { so2: normalize_pollutant_value(station, pollutant_td_index[:so2]),
                  no2: normalize_pollutant_value(station, pollutant_td_index[:no2]),
                  co: normalize_pollutant_value(station, pollutant_td_index[:co]),
                  o3: normalize_pollutant_value(station, pollutant_td_index[:o3]),
                  pm10: normalize_pollutant_value(station, pollutant_td_index[:pm10]),
                  pm2_5: normalize_pollutant_value(station, pollutant_td_index[:pm2_5]) }

    unless station.nil?
      if station.css('td')[1].content == "Ambasada SAD" && pollutants[:pm2_5].nil?
          pollutants[:pm2_5] = us_embassy_pm2_5_aqicn
      end
    end

    pollutants[:aqi] = calculate_total_aqi(pollutants)
    add_aqi_descriptor(pollutants)
  end

  def normalize_pollutant_value(station, index)
    # hard-coded, potential problems if source table changes
    # when pollutant AQI is not meassured, value is shown as "" or nil or "*" or "0"
    # when pollutant AQI is meassured, value is shown as "some_number" or "0" 
    # in order to know wether "0" represents actual value or lack of measurement, previous table's 'td' has to be checked, 
    # if it contains "google_map/images/b.png" (green circle) it is an actual value, otherwise it's not
    return nil if station.nil?
    scraped_data = station.css('td')[index]&.content

    if scraped_data == "0"
      prior_td_field = station.css('td')[index-1]&.css('img')&.first&.attributes&.values&.first&.value
      if prior_td_field == "google_map/images/b.png"
        return 0
      else
        return nil
      end
    end

    if scraped_data == "*" || scraped_data&.empty? || scraped_data.nil? 
      nil
    else
      scraped_data.to_i
    end
  end

  # https://en.wikipedia.org/w/index.php?title=Air_quality_index#Computing_the_AQI
  # If multiple pollutants are measured at a monitoring site, 
  # then the largest or "dominant" AQI value is reported for the location.
  #
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
  def calculate_total_aqi(pollutants)
    # replacing pm10 and pm2.5 with the highest value of the two, 
    # if their AQI is "unhealthy" or worse, total AQI will only take the highest value of the two for calculation
    # if it's not, total AQI just takes the highest AQI value from all pollutants anyway 
    pollutants[:pm] = [pollutants[:pm10], pollutants[:pm2_5]].compact.max

    # getting two max pollutants AQI values
    pollutants = pollutants.reject { |k,v| k if k == :pm10 || k== :pm2_5 || v.nil? }
    pollutants = pollutants.values.sort { |a, b| b <=> a }.first(2)

    max_value = pollutants.max
    return max_value if max_value.nil? || pollutants.count == 1 # US embassy only measures pm2.5

    if pollutants.all? { |x| x >= AQI[:hazardous][:value].first } #301
      # In the case when the concentrations of two or more pollutants are within the "hazardous" category, 
      # a value of up to 100 index points is added, with the maximum total number of Index values ​​not exceeding 500.
      max_value += 100
      if max_value > 500
        500
      else
        max_value
      end
    elsif pollutants.all? { |x| x >= AQI[:very_unhealthy][:value].first } #201
      # 100 index numbers (in the case when two or more pollutants are in the category "very unhealthy")
      max_value += 100
    elsif pollutants.all? { |x| x >= AQI[:unhealthy][:value].first } #101
      # adding 50 index numbers (in the case when two or more pollutants in the category "unhealthy")
      max_value += 50
    else
      max_value
    end
  end

  def add_aqi_descriptor(pollutants)
    pollutants.each do |k, v|
      (key, values) =  AQI.select { |_x, y| y[:value].include?(v) }.first
      pollutants[k] = { value: v, 
                        class: v.nil? ? '' : key.to_s,
                        advisory: v.nil? ? '' : values[:advisory],
                        who: v.nil? ? '' : values[:who] }
    end
    pollutants
  end

  def current_air_pollution_for_city(pollutants)
    city_pollutants = { so2: pollutants.values.map { |v| v[:so2][:value] }.compact.max,
                        no2: pollutants.values.map { |v| v[:no2][:value] }.compact.max,
                        co: pollutants.values.map { |v| v[:co][:value] }.compact.max,
                        o3: pollutants.values.map { |v| v[:o3][:value] }.compact.max,
                        pm10: pollutants.values.map { |v| v[:pm10][:value] }.compact.max,
                        pm2_5: pollutants.values.map { |v| v[:pm2_5][:value] }.compact.max }

    city_pollutants[:aqi] = calculate_total_aqi(city_pollutants)
    add_aqi_descriptor(city_pollutants)
  end

  def us_embassy_pm2_5_aqicn
    aqicn_website = Nokogiri::HTML(URI.open('https://aqicn.org/city/bosnia-herzegovina/sarajevo/us-embassy/'))
    pm2_5 = aqicn_website.css('.aqivalue').first.content.to_i
    time = Time.parse(aqicn_website.css('span#aqiwgtutime').first.content[11..]).strftime( "%d.%m.%Y. %H")

    if time != Time.now.strftime( "%d.%m.%Y. %H")
      pm2_5 = nil
    end

    pm2_5
  end
end