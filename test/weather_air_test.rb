require_relative 'test_helper'

class WeatherAirTest < Minitest::Test
  def test_total_AQI_calculation_in_category_moderate
    script = WeatherAir.new
    pollutants = { so2: 10, no2: 20, co: 30, o3: 40, pm10: 50, pm2_5: 60}
    total_AQI = script.send(:calculate_total_aqi, pollutants)
    assert_equal total_AQI, 60
  end 
  def test_total_AQI_calculation_in_category_unhealthy
    script = WeatherAir.new
    pollutants = { so2: 10, no2: 20, co: 30, o3: 190, pm10: 150, pm2_5: 180}
    total_AQI = script.send(:calculate_total_aqi, pollutants)
    assert_equal total_AQI, 240
  end
  
  def test_total_AQI_calculation_in_category_very_unhealthy
    script = WeatherAir.new
    pollutants = { so2: 10, no2: 20, co: 270, o3: 190, pm10: 250, pm2_5: 240}
    total_AQI = script.send(:calculate_total_aqi, pollutants)
    assert_equal total_AQI, 370
  end 

  def test_total_AQI_calculation_in_category_very_hazardous
    script = WeatherAir.new
    pollutants = { so2: 10, no2: 20, co: 470, o3: 190, pm10: 450, pm2_5: 440}
    total_AQI = script.send(:calculate_total_aqi, pollutants)
    assert_equal total_AQI, 500
  end

  def test_total_AQI_calculation_with_one_pollutant_in_category_very_hazardous
    script = WeatherAir.new
    pollutants = { so2: 10, no2: 60, co: 120, o3: 190, pm10: 250, pm2_5: 380}
    total_AQI = script.send(:calculate_total_aqi, pollutants)
    assert_equal total_AQI, 430
  end
  
  def test_adding_AQI_descriptor
    script = WeatherAir.new
    pollutants = { so2: 10, no2: 60, co: 120, o3: 190, pm10: 250, pm2_5: 380, aqi: 430}
    expected = { :so2 => { value: 10, class: 'good' },
                 :no2 => { value: 60, class: 'moderate' }, 
                 :co => { value: 120, class: 'unhealthy_for_sensitive_groups' },
                 :o3 => { value: 190, class: 'unhealthy' },
                 :pm10 => { value: 250, class: 'very_unhealthy' },
                 :pm2_5 => { value: 380, class: 'hazardous' },
                 :aqi => { value: 430, class: 'hazardous'} }
    result = script.send(:add_aqi_descriptor, pollutants)
    assert_equal result, expected
  end
end