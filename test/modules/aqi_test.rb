require_relative '../test_helper'

class WeatherAirTest < Minitest::Test
  def setup 
    @script = WeatherAir.new
    @stations_pollutants = { "vijecnica" => {:so2=>{:value=>9, :class=>"good"},
                                             :no2=>{:value=>31, :class=>"good"},
                                             :co=>{:value=>nil, :class=>""},
                                             :o3=>{:value=>nil, :class=>""},
                                             :pm10=>{:value=>38, :class=>"good"},
                                             :pm2_5=>{:value=>nil, :class=>""},
                                             :pm=>{:value=>38, :class=>"good"},
                                             :aqi=>{:value=>38, :class=>"good"},
                                             :name=>"Vijećnica",
                                             :latitude=>43.859,
                                             :longitude=>18.434},
                "bjelave"=> {:so2=>{:value=>10, :class=>"good"},
                            :no2=>{:value=>36, :class=>"good"},
                            :co=>{:value=>13, :class=>"good"},
                            :o3=>{:value=>15, :class=>"good"},
                            :pm10=>{:value=>87, :class=>"moderate"},
                            :pm2_5=>{:value=>160, :class=>"unhealthy"},
                            :pm=>{:value=>160, :class=>"unhealthy"},
                            :aqi=>{:value=>160, :class=>"unhealthy"},
                            :name=>"Bjelave",
                            :latitude=>43.867,
                            :longitude=>18.42},
                "embassy"=>{:so2=>{:value=>nil, :class=>""},
                            :no2=>{:value=>nil, :class=>""},
                            :co=>{:value=>nil, :class=>""},
                            :o3=>{:value=>nil, :class=>""},
                            :pm10=>{:value=>nil, :class=>""},
                            :pm2_5=>{:value=>165, :class=>"unhealthy"},
                            :pm=>{:value=>165, :class=>"unhealthy"},
                            :aqi=>{:value=>165, :class=>"unhealthy"},
                            :name=>"Ambasada SAD",
                            :latitude=>43.856,
                            :longitude=>18.397},
                "otoka"=> {:so2=>{:value=>9, :class=>"good"},
                            :no2=>{:value=>28, :class=>"good"},
                            :co=>{:value=>nil, :class=>""},
                            :o3=>{:value=>nil, :class=>""},
                            :pm10=>{:value=>123, :class=>"unhealthy_for_sensitive_groups"},
                            :pm2_5=>{:value=>nil, :class=>""},
                            :pm=>{:value=>123, :class=>"unhealthy_for_sensitive_groups"},
                            :aqi=>{:value=>123, :class=>"unhealthy_for_sensitive_groups"},
                            :name=>"Otoka",
                            :latitude=>43.848,
                            :longitude=>18.363},
                "ilidza"=> {:so2=>{:value=>4, :class=>"good"},
                            :no2=>{:value=>20, :class=>"good"},
                            :co=>{:value=>nil, :class=>""},
                            :o3=>{:value=>nil, :class=>""},
                            :pm10=>{:value=>86, :class=>"moderate"},
                            :pm2_5=>{:value=>159, :class=>"unhealthy"},
                            :pm=>{:value=>159, :class=>"unhealthy"},
                            :aqi=>{:value=>159, :class=>"unhealthy"},
                            :name=>"Ilidža",
                            :latitude=>43.83,
                            :longitude=>18.31}}
  end

  def teardown
    Timecop.return
  end

  def test_stations_pollutants_aqi_data_no_us_embassy_data_at_fhmzbih
    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
      to_return(status: 200, body: File.read('test/fixtures/fhmzbih.html'), headers: {})

    Timecop.freeze(Time.local(2023, 12, 19, 14, 30, 0))

    stub_request(:get, "https://aqicn.org/city/bosnia-herzegovina/sarajevo/us-embassy/").
    to_return(status: 200, body: File.read('test/fixtures/aqicn.html'), headers: {})
          
    data = @script.stations_pollutants_aqi_data

    assert_equal(@stations_pollutants, data)
  end

  def test_stations_pollutants_aqi_data
    stub_request(:get, "https://www.fhmzbih.gov.ba/latinica/ZRAK/AQI-satne.php").
      to_return(status: 200, body: File.read('test/fixtures/fhmzbih_us_embassy.html'), headers: {})
          
    data = @script.stations_pollutants_aqi_data
    assert_equal(@stations_pollutants, data)
  end

  def test_city_pollutants_aqi
    data = @script.city_pollutants_aqi(@stations_pollutants)
    expected = {:so2=>{:value=>10, :class=>"good"},
                :no2=>{:value=>36, :class=>"good"},
                :co=>{:value=>13, :class=>"good"},
                :o3=>{:value=>15, :class=>"good"},
                :pm10=>{:value=>123, :class=>"unhealthy_for_sensitive_groups"},
                :pm2_5=>{:value=>165, :class=>"unhealthy"},
                :pm=>{:value=>165, :class=>"unhealthy"},
                :aqi=>
                {:value=>165,
                  :class=>"unhealthy",
                  :advisory=>
                  "<b>Sensitive groups</b>: Avoid long or intense outdoor activities.\n" +
                  "                        Consider rescheduling or moving activities indoors.\n" +
                  "                        <br><br>\n" +
                  "                        <b>Everyone else</b>: Reduce long or intense activities. Take\n" +
                  "                        more breaks during outdoor activities.",
                  :who=>"Everyone"}}
                  
    assert_equal(expected, data)
  end

end


