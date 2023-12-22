require_relative '../test_helper'

class AirQualityIndexTest < Minitest::Test
  def setup 
    @script = WeatherAir::AirQualityIndex.new
    @stations_pollutants = { "vijecnica" => {:so2 => { :value=>9, :class=>"good" },
                                             :no2 => { :value=>31, :class=>"good" },
                                             :co => { :value=>nil, :class=>"" },
                                             :o3 => { :value=>nil, :class=>"" },
                                             :pm10 => { :value=>38, :class=>"good" },
                                             :pm2_5 => { :value=>nil, :class=>"" },
                                             :pm => { :value=>38, :class=>"good" },
                                             :aqi => { :value=>38, :class=>"good" },
                                             :name=>"Vijećnica",
                                             :latitude=>43.859,
                                             :longitude=>18.434},
                "bjelave"=> {:so2 => { :value=>10, :class=>"good" },
                            :no2 => { :value=>36, :class=>"good" },
                            :co => { :value=>13, :class=>"good" },
                            :o3 => { :value=>15, :class=>"good" },
                            :pm10 => { :value=>87, :class=>"moderate" },
                            :pm2_5 => { :value=>160, :class=>"unhealthy" },
                            :pm => { :value=>160, :class=>"unhealthy" },
                            :aqi => { :value=>160, :class=>"unhealthy" },
                            :name=>"Bjelave",
                            :latitude=>43.867,
                            :longitude=>18.42},
                "embassy" => { :so2 => { :value=>nil, :class=>"" },
                            :no2 => { :value=>nil, :class=>"" },
                            :co => { :value=>nil, :class=>"" },
                            :o3 => { :value=>nil, :class=>"" },
                            :pm10 => { :value=>nil, :class=>"" },
                            :pm2_5 => { :value=>165, :class=>"unhealthy" },
                            :pm => { :value=>165, :class=>"unhealthy" },
                            :aqi => { :value=>165, :class=>"unhealthy" },
                            :name=>"Ambasada SAD",
                            :latitude=>43.856,
                            :longitude=>18.397},
                "otoka"=> {:so2 => { :value=>9, :class=>"good" },
                            :no2 => { :value=>28, :class=>"good" },
                            :co => { :value=>nil, :class=>"" },
                            :o3 => { :value=>nil, :class=>"" },
                            :pm10 => { :value=>123, :class=>"unhealthy_for_sensitive_groups" },
                            :pm2_5 => { :value=>nil, :class=>"" },
                            :pm => { :value=>123, :class=>"unhealthy_for_sensitive_groups" },
                            :aqi => { :value=>123, :class=>"unhealthy_for_sensitive_groups" },
                            :name=>"Otoka",
                            :latitude=>43.848,
                            :longitude=>18.363},
                "ilidza"=> {:so2 => { :value=>4, :class=>"good" },
                            :no2 => { :value=>20, :class=>"good" },
                            :co => { :value=>nil, :class=>"" },
                            :o3 => { :value=>nil, :class=>"" },
                            :pm10 => { :value=>86, :class=>"moderate" },
                            :pm2_5 => { :value=>159, :class=>"unhealthy" },
                            :pm => { :value=>159, :class=>"unhealthy" },
                            :aqi => { :value=>159, :class=>"unhealthy" },
                            :name=>"Ilidža",
                            :latitude=>43.83,
                            :longitude=>18.31}}
  end

  def teardown
    Timecop.return
  end

  def test_stations_pollutants_aqi_data_no_us_embassy_data_at_fhmzbih
    # skip
    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
      to_return(status: 200, body: File.read('test/fixtures/fhmzbih.html'), headers: {})

    Timecop.freeze(Time.local(2023, 12, 19, 14, 30, 0))

    stub_request(:get, "https://aqicn.org/city/bosnia-herzegovina/sarajevo/us-embassy/").
    to_return(status: 200, body: File.read('test/fixtures/aqicn.html'), headers: {})
          
    data = @script.stations_pollutants_aqi_data

    assert_equal(@stations_pollutants, data)
  end

  def test_stations_pollutants_aqi_data
    # skip
    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
      to_return(status: 200, body: File.read('test/fixtures/fhmzbih_us_embassy.html'), headers: {})
          
    data = @script.stations_pollutants_aqi_data
    assert_equal(@stations_pollutants, data)
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
    @script.expects(:stations_pollutants_aqi_data).returns(stations_pollutants)
    assert_equal(expected, @script.send(:city_pollutants_aqi))
  end

  def test_city_pollutants_aqi
    # skip
    @script.expects(:stations_pollutants_aqi_data).returns(@stations_pollutants)
    data = @script.city_pollutants_aqi
    expected = {:so2 => { :value=>10, :class=>"good" },
                :no2 => { :value=>36, :class=>"good" },
                :co => { :value=>13, :class=>"good" },
                :o3 => { :value=>15, :class=>"good" },
                :pm10 => { :value=>123, :class=>"unhealthy_for_sensitive_groups" },
                :pm2_5 => { :value=>165, :class=>"unhealthy" },
                :pm => { :value=>165, :class=>"unhealthy" },
                :aqi => { :value=>165, :class=>"unhealthy" } }

    assert_equal(expected, data)
  end

end


