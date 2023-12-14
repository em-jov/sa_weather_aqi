require_relative 'test_helper'

class WeatherAirTest < Minitest::Test
  def setup 
    @script = WeatherAir.new
  end

  def test_no_data
    # skip 
    pollutants = { so2: nil, no2: nil, co: nil, o3: nil, pm10: nil, pm2_5: nil}
    assert_nil(@script.send(:calculate_total_aqi, pollutants))
  end

  def test_total_AQI_calculation_in_category_moderate
    # skip
    pollutants = { so2: 10, no2: 20, co: 30, o3: 40, pm10: 50, pm2_5: 60}
    assert_equal(@script.send(:calculate_total_aqi, pollutants), 60)
  end 

  def test_total_AQI_calculation_in_category_unhealthy
    # skip
    pollutants = { so2: 10, no2: 20, co: 30, o3: 190, pm10: 150, pm2_5: 180}
    assert_equal(@script.send(:calculate_total_aqi, pollutants),240)
  end

  def test_total_AQI_calculation_in_category_very_unhealthy
    # skip
    pollutants = { so2: 10, no2: 20, co: 270, o3: 190, pm10: 250, pm2_5: 240}
    assert_equal(@script.send(:calculate_total_aqi, pollutants), 370)
  end 

  def test_total_AQI_calculation_in_category_very_hazardous
    # skip
    pollutants = { so2: 10, no2: 20, co: 470, o3: 190, pm10: 450, pm2_5: 440}
    assert_equal(@script.send(:calculate_total_aqi, pollutants),500)
  end

  def test_total_AQI_calculation_with_one_pollutant_in_category_very_hazardous
    # skip
    pollutants = { so2: 10, no2: 60, co: 120, o3: 190, pm10: 250, pm2_5: 380}
    assert_equal( @script.send(:calculate_total_aqi, pollutants), 430)
  end
  
  def test_total_AQI_calculation_for_US_embassy
    # skip
    pollutants = { pm2_5: 380}
    assert_equal(@script.send(:calculate_total_aqi, pollutants), 380)
  end

  def test_adding_AQI_descriptor
    pollutants = { so2: 10, no2: 60, co: 120, o3: 190, pm10: 250, pm2_5: 380, aqi: 430}
    expected = { :so2 => { value: 10, class: 'good' },
                 :no2 => { value: 60, class: 'moderate' }, 
                 :co => { value: 120, class: 'unhealthy_for_sensitive_groups' },
                 :o3 => { value: 190, class: 'unhealthy' },
                 :pm10 => { value: 250, class: 'very_unhealthy' },
                 :pm2_5 => { value: 380, class: 'hazardous' },
                 :aqi => { value: 430, class: 'hazardous'} }
    result = @script.send(:add_aqi_descriptor, pollutants)
    result.each do |k, v|
      v.delete(:who)
      v.delete(:advisory) 
    end
    assert_equal result, expected
  end
end