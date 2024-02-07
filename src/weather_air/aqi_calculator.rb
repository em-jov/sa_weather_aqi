module WeatherAir
  class AqiCalculator

    def self.convert_concentration_to_aqi(pollutant_name, pollutant_value)
      pollutant_value = pollutant_value.to_f
      case pollutant_name    
      when "so2", "SO2"
        convert_so2_concentration_to_aqi(pollutant_value)
      when "no2", "NO2"
        convert_no2_concentration_to_aqi(pollutant_value)
      when "co", "CO"
        convert_co_concentration_to_aqi(pollutant_value)
      when "o3", "O3"
        convert_o3_concentration_to_aqi(pollutant_value)
      when "pm10", "PM10"
        convert_pm10_concentration_to_aqi(pollutant_value)
      when "pm25", "pm2_5", "pm2.5", "PM25", "PM2.5", "PM2_5"
        convert_pm2_5_concentration_to_aqi(pollutant_value)
      end
    end

    def self.convert_pm2_5_concentration_to_aqi(pm25)
      breakpoints = [
        { conc_low: 0.0, conc_high: 12.0, iaqi_low: 0, iaqi_high: 50 },
        { conc_low: 12.1, conc_high: 35.4, iaqi_low: 51, iaqi_high: 100 },
        { conc_low: 35.5, conc_high: 55.4, iaqi_low: 101, iaqi_high: 150 },
        { conc_low: 55.5, conc_high: 150.4, iaqi_low: 151, iaqi_high: 200 },
        { conc_low: 150.5, conc_high: 250.4, iaqi_low: 201, iaqi_high: 300 },
        { conc_low: 250.5, conc_high: 350.4, iaqi_low: 301, iaqi_high: 400 },
        { conc_low: 350.5, conc_high: 500.4, iaqi_low: 401, iaqi_high: 500 },
      ]
    
      breakpoint = breakpoints.find { |b| pm25 >= b[:conc_low] && pm25 <= b[:conc_high] }
      return nil unless breakpoint

      aqi = ((breakpoint[:iaqi_high] - breakpoint[:iaqi_low]) / (breakpoint[:conc_high] - breakpoint[:conc_low])) *
            (pm25 - breakpoint[:conc_low]) + breakpoint[:iaqi_low]
    
      aqi.round 
    end

    def self.convert_pm10_concentration_to_aqi(pm10)
      breakpoints = [
        { low: 0, high: 54, ilow: 0, ihigh: 50 },
        { low: 55, high: 154, ilow: 51, ihigh: 100 },
        { low: 155, high: 254, ilow: 101, ihigh: 150 },
        { low: 255, high: 354, ilow: 151, ihigh: 200 },
        { low: 355, high: 424, ilow: 201, ihigh: 300 },
        { low: 425, high: 504, ilow: 301, ihigh: 400 },
        { low: 505, high: Float::INFINITY, ilow: 401, ihigh: 500 }
      ]
    
      breakpoint = breakpoints.find { |range| pm10.between?(range[:low], range[:high]) }
    
      if breakpoint
        c_low, c_high, i_low, i_high = breakpoint[:low], breakpoint[:high], breakpoint[:ilow], breakpoint[:ihigh]
        aqi = ((i_high - i_low) / (c_high - c_low).to_f) * (pm10 - c_low) + i_low
        return aqi.round
      else
        aqi = ((500 - 401) / (Float::INFINITY - 505).to_f) * (pm10 - 505) + 401
        return aqi.round
      end
    end

    def self.convert_co_concentration_to_aqi(co)
      breakpoints = [
        { low: 0, high: 4.4, ilow: 0, ihigh: 50 },
        { low: 4.5, high: 9.4, ilow: 51, ihigh: 100 },
        { low: 9.5, high: 12.4, ilow: 101, ihigh: 150 },
        { low: 12.5, high: 15.4, ilow: 151, ihigh: 200 },
        { low: 15.5, high: 30.4, ilow: 201, ihigh: 300 },
        { low: 30.5, high: Float::INFINITY, ilow: 301, ihigh: 500 }
      ]
    
      breakpoint = breakpoints.find { |range| co.between?(range[:low], range[:high]) }
    
      if breakpoint
        c_low, c_high, i_low, i_high = breakpoint[:low], breakpoint[:high], breakpoint[:ilow], breakpoint[:ihigh]
        aqi = ((i_high - i_low) / (c_high - c_low).to_f) * (co - c_low) + i_low
        return aqi.round
      else
        # Linear extrapolation for values outside defined ranges
        aqi = ((500 - 301) / (Float::INFINITY - breakpoints.last[:high]).to_f) * (co - breakpoints.last[:high]) + 301
        return [aqi.round, 500].min  # Ensure the extrapolated value is capped at 500
      end
    end

    # not okay
    def self.convert_so2_concentration_to_aqi(so2)
      breakpoints = [
        { low: 0, high: 35, ilow: 0, ihigh: 50 },
        { low: 36, high: 75, ilow: 51, ihigh: 100 },
        { low: 76, high: 185, ilow: 101, ihigh: 150 },
        { low: 186, high: 304, ilow: 151, ihigh: 200 },
        { low: 305, high: 604, ilow: 201, ihigh: 300 },
        { low: 605, high: Float::INFINITY, ilow: 301, ihigh: 500 }
      ]
    
      breakpoint = breakpoints.find { |range| so2.between?(range[:low], range[:high]) }
    
      if breakpoint
        c_low, c_high, i_low, i_high = breakpoint[:low], breakpoint[:high], breakpoint[:ilow], breakpoint[:ihigh]
        aqi = ((i_high - i_low) / (c_high - c_low).to_f) * (so2 - c_low) + i_low
        return aqi.round
      else
        aqi = ((500 - 301) / (Float::INFINITY - 605).to_f) * (so2 - 605) + 301
        return aqi.round
      end
    end

    # not okay
    def self.convert_no2_concentration_to_aqi(no2)
      breakpoints = [
        { low: 0, high: 53, ilow: 0, ihigh: 50 },
        { low: 54, high: 100, ilow: 51, ihigh: 100 },
        { low: 101, high: 360, ilow: 101, ihigh: 150 },
        { low: 361, high: 649, ilow: 151, ihigh: 200 },
        { low: 650, high: 1249, ilow: 201, ihigh: 300 },
        { low: 1250, high: Float::INFINITY, ilow: 301, ihigh: 500 }
      ]
    
      breakpoint = breakpoints.find { |range| no2.between?(range[:low], range[:high]) }
    
      if breakpoint
        c_low, c_high, i_low, i_high = breakpoint[:low], breakpoint[:high], breakpoint[:ilow], breakpoint[:ihigh]
        aqi = ((i_high - i_low) / (c_high - c_low).to_f) * (no2 - c_low) + i_low
        return aqi.round
      else
        # Linear extrapolation for values outside defined ranges
        aqi = ((500 - 301) / (Float::INFINITY - breakpoints.last[:high]).to_f) * (no2 - breakpoints.last[:high]) + 301
        return [aqi.round, 500].min  # Ensure the extrapolated value is capped at 500
      end
    end

    # not okay
    def self.convert_o3_concentration_to_aqi(o3_8hr)
      breakpoints = [
        { low: 0, high: 54, ilow: 0, ihigh: 50 },
        { low: 55, high: 70, ilow: 51, ihigh: 100 },
        { low: 71, high: 85, ilow: 101, ihigh: 150 },
        { low: 86, high: 105, ilow: 151, ihigh: 200 },
        { low: 106, high: 200, ilow: 201, ihigh: 300 },
        { low: 201, high: Float::INFINITY, ilow: 301, ihigh: 500 }
      ]
    
      breakpoints.each do |range|
        if o3_8hr.between?(range[:low], range[:high])
          c_low, c_high, i_low, i_high = range[:low], range[:high], range[:ilow], range[:ihigh]
          aqi = ((i_high - i_low) / (c_high - c_low).to_f) * (o3_8hr - c_low) + i_low
          return aqi.round
        end
      end
    
      # If the concentration is outside the defined ranges, default to the highest AQI value (500)
      return 500
    end

    def self.convert_pm10_aqi_to_concentration(aqi)
      breakpoints = [
        { bp_high: 50, conc_low: 0, conc_high: 54, iaqi_low: 0, iaqi_high: 50 },
        { bp_high: 100, conc_low: 55, conc_high: 154, iaqi_low: 51, iaqi_high: 100 },
        { bp_high: 150, conc_low: 155, conc_high: 254, iaqi_low: 101, iaqi_high: 150 },
        { bp_high: 200, conc_low: 255, conc_high: 354, iaqi_low: 151, iaqi_high: 200 },
        { bp_high: 300, conc_low: 355, conc_high: 424, iaqi_low: 201, iaqi_high: 300 },
        { bp_high: 400, conc_low: 425, conc_high: 504, iaqi_low: 301, iaqi_high: 400 },
        { bp_high: 500, conc_low: 505, conc_high: 604, iaqi_low: 401, iaqi_high: 500 },
      ]
    
    
      breakpoint = breakpoints.find { |b| aqi <= b[:bp_high] }
      return nil unless breakpoint
      
      conc = ((aqi - breakpoint[:iaqi_low]) * (breakpoint[:conc_high] - breakpoint[:conc_low]) / 
              (breakpoint[:iaqi_high] - breakpoint[:iaqi_low])) + breakpoint[:conc_low]
    
      conc.round(2)
    end
    
  end
end