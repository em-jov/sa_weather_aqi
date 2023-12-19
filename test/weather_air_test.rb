require_relative 'test_helper'

class WeatherAirTest < Minitest::Test
  def setup 
    @script = WeatherAir.new
  end

  # calculate_total_aqi
  def test_no_data
    # skip 
    pollutants = { so2: nil, no2: nil, co: nil, o3: nil, pm10: nil, pm2_5: nil }
    assert_nil(@script.send(:calculate_total_aqi, pollutants))
  end

  def test_total_AQI_calculation_in_category_moderate
    # skip
    pollutants = { so2: 10, no2: 20, co: 30, o3: 40, pm10: 50, pm2_5: 60 }
    assert_equal(60, @script.send(:calculate_total_aqi, pollutants))
  end 

  def test_total_AQI_calculation_in_category_unhealthy
    # skip
    pollutants = { so2: 10, no2: 20, co: 30, o3: 190, pm10: 150, pm2_5: 180 }
    assert_equal(240, @script.send(:calculate_total_aqi, pollutants))
  end

  def test_total_AQI_calculation_in_category_very_unhealthy
    # skip
    pollutants = { so2: 10, no2: 20, co: 270, o3: 190, pm10: 250, pm2_5: 240 }
    assert_equal(370, @script.send(:calculate_total_aqi, pollutants))
  end 

  def test_total_AQI_calculation_in_category_very_hazardous
    # skip
    pollutants = { so2: 10, no2: 20, co: 470, o3: 190, pm10: 450, pm2_5: 440 }
    assert_equal(500, @script.send(:calculate_total_aqi, pollutants))
  end

  def test_total_AQI_calculation_with_one_pollutant_in_category_very_hazardous
    # skip
    pollutants = { so2: 10, no2: 60, co: 120, o3: 190, pm10: 250, pm2_5: 380 }
    assert_equal(430, @script.send(:calculate_total_aqi, pollutants))
  end
  
  def test_total_AQI_calculation_for_US_embassy
    # skip
    pollutants = { pm2_5: 380 }
    assert_equal(380, @script.send(:calculate_total_aqi, pollutants))
  end

  # add_aqi_descriptor

  def test_adding_AQI_descriptor_no_value
    # skip
    pollutants = { so2: nil, no2: nil, co: nil, o3: nil, pm10: nil, pm2_5: nil, aqi: nil }
    expected = { :so2 => { value: nil, class: '' },
                 :no2 => { value: nil, class: '' }, 
                 :co => { value: nil, class: '' },
                 :o3 => { value: nil, class: '' },
                 :pm10 => { value: nil, class: '' },
                 :pm2_5 => { value: nil, class: '' },
                 :aqi => { value: nil, class: '' } }
    assert_equal(expected, @script.send(:add_aqi_descriptor, pollutants))
  end

  def test_adding_AQI_descriptor
    # skip
    pollutants = { so2: 10, no2: 60, co: 120, o3: 190, pm10: 250, pm2_5: 380, aqi: 430 }
    expected = { :so2 => { value: 10, class: 'good' },
                 :no2 => { value: 60, class: 'moderate' }, 
                 :co => { value: 120, class: 'unhealthy_for_sensitive_groups' },
                 :o3 => { value: 190, class: 'unhealthy' },
                 :pm10 => { value: 250, class: 'very_unhealthy' },
                 :pm2_5 => { value: 380, class: 'hazardous' },
                 :aqi => { value: 430, class: 'hazardous' } }
    assert_equal(expected, @script.send(:add_aqi_descriptor, pollutants))
  end

  # city_pollutants_aqi
  def test_getting_citys_pollutants_aqi_no_values
    # skip
    stations_pollutants = { "vijecnica" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "bjelave" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "embassy" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "otoka" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "ilidza" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil} }

    expected = { :so2 => { :value => nil, :class => "" },
                 :no2 => { :value => nil, :class => "" },
                 :co => { :value => nil, :class => "" },
                 :o3 => { :value => nil, :class => "" },
                 :pm10 => { :value => nil, :class => "" },
                 :pm2_5 => { :value => nil, :class => "" },
                 :pm => { :value => nil, :class => "" },
                 :aqi => { :value => nil, :class => "" } }

    assert_equal(expected, @script.send(:city_pollutants_aqi, stations_pollutants))
  end

  def test_getting_citys_pollutants_aqi
    # skip
    stations_pollutants = {"vijecnica"=> { :name => "Vijećnica",
                                            :so2 => { :value => 3, :class => "good" },
                                            :no2 => { :value => 7, :class => "good" },
                                            :co => { :value => nil, :class => "" },
                                            :o3 => { :value => nil, :class => "" },
                                            :pm10 => { :value => 13, :class => "good" },
                                            :pm2_5 => { :value => nil, :class => "" },
                                            :aqi => { :value => 13, :class => "good" } },
                        "bjelave"=> { :name => "Bjelave",
                                      :so2 => { :value => 4, :class => "good" },
                                      :no2 => { :value => 2, :class => "good" },
                                      :co => { :value => 4, :class => "good" },
                                      :o3 => { :value => 23, :class => "good" },
                                      :pm10 => { :value => 14, :class => "good" },
                                      :pm2_5 => { :value => 38, :class => "good" },
                                      :aqi => { :value => 38, :class => "good"} },
                        "embassy"=> { :name => "Ambasada SAD",
                                      :so2 => { :value => nil, :class => "" },
                                      :no2 => { :value => nil, :class => "" },
                                      :co => { :value => nil, :class => "" },
                                      :o3 => { :value => nil, :class => "" },
                                      :pm10 => { :value => nil, :class => "" },
                                      :pm2_5 => { :value => nil, :class => "" },
                                      :aqi => { :value => nil, :class => ""} },
                        "otoka"=> { :name => "Otoka",
                                    :so2 => { :value => 5, :class => "good" },
                                    :no2 => { :value => 15, :class => "good" },
                                    :co => { :value => nil, :class => "" },
                                    :o3 => { :value => nil, :class => "" },
                                    :pm10 => { :value => 19, :class => "good" },
                                    :pm2_5 => { :value => nil, :class => "" },
                                    :aqi => { :value => 19, :class => "good"} },
                        "ilidza"=> { :name => "Ilidža",
                                     :so2 => { :value => 3, :class => "good" },
                                     :no2 => { :value => 7, :class => "good" },
                                     :co => { :value => nil, :class => "" },
                                     :o3 => { :value => nil, :class => "" },
                                     :pm10 => { :value => 40, :class => "good" },
                                     :pm2_5 => { :value => 80, :class => "moderate" },
                                     :aqi => { :value => 80, :class => "moderate"} } }

    expected = {:so2=>{:value=>5, :class=>"good"},
                :no2=>{:value=>15, :class=>"good"},
                :co=>{:value=>4, :class=>"good"},
                :o3=>{:value=>23, :class=>"good"},
                :pm10=>{:value=>40, :class=>"good"},
                :pm2_5=>{:value=>80, :class=>"moderate"},
                :pm=>{:value=>80, :class=>"moderate"},
                :aqi=>
                {:value=>80,
                  :class=>"moderate",
                  :advisory=>
                  "<b>Unusually sensitive people</b>: Consider making outdoor activities shorter and less intense.\n" +
                  "              Watch for symptoms such as coughing or shortness of breath. These are signs to take it easier. \n" +
                  "              <br><br> \n" +
                  "              <b>Everyone else</b>: It’s a good day to be active outside.",
                  :who=>"Some people who may be unusually sensitive to particle pollution."}}

    assert_equal(expected, @script.send(:city_pollutants_aqi, stations_pollutants))
  end

end

