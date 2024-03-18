require_relative '../test_helper'

class AirQualityIndexTest < Minitest::Test
  def setup 
    @script = WeatherAir::AirQualityIndex.new
    @stations_pollutants = {
    "vijecnica"=>{:aqi=>{:value=>"1", :class=>:good_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"", :class=>nil}, :pm10=>{:value=>"", :class=>nil}, :pm25=>{:value=>"", :class=>nil}, :name=>"Vijećnica", :latitude=>43.859, :longitude=>18.434},
    "bjelave"=>{:aqi=>{:value=>"3", :class=>:moderate_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"3", :class=>:moderate_eea}, :pm10=>{:value=>"1", :class=>:good_eea}, :pm25=>{:value=>"1", :class=>:good_eea}, :name=>"Bjelave", :latitude=>43.867, :longitude=>18.42},
    "otoka"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"2", :class=>:fair_eea}, :o3=>{:value=>"2", :class=>:fair_eea}, :pm10=>{:value=>"2", :class=>:fair_eea}, :pm25=>{:value=>"2", :class=>:fair_eea}, :name=>"Otoka", :latitude=>43.848, :longitude=>18.363},
    "ilidza"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"", :class=>nil}, :pm10=>{:value=>"2", :class=>:fair_eea}, :pm25=>{:value=>"2", :class=>:fair_eea}, :name=>"Ilidža", :latitude=>43.83, :longitude=>18.31},
    "vogosca"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"", :class=>nil}, :pm10=>{:value=>"2", :class=>:fair_eea}, :pm25=>{:value=>"1", :class=>:good_eea}, :name=>"Vogošća", :latitude=>43.9, :longitude=>18.342},
    "hadzici"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"2", :class=>:fair_eea}, :pm10=>{:value=>"", :class=>nil}, :pm25=>{:value=>"", :class=>nil}, :name=>"Hadžići", :latitude=>43.823, :longitude=>18.2},
    "ilijas"=>{:aqi=>{:value=>"2", :class=>:fair_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"", :class=>nil}, :pm10=>{:value=>"2", :class=>:fair_eea}, :pm25=>{:value=>" ", :class=>nil}, :name=>"Ilijaš", :latitude=>43.96, :longitude=>18.269},
    "ivan_sedlo"=>{:aqi=>{:value=>"3", :class=>:moderate_eea}, :so2=>{:value=>"1", :class=>:good_eea}, :no2=>{:value=>"1", :class=>:good_eea}, :o3=>{:value=>"3", :class=>:moderate_eea}, :pm10=>{:value=>"1", :class=>:good_eea}, :pm25=>{:value=>"", :class=>nil}, :name=>"Ivan sedlo", :latitude=>43.75, :longitude=>18.035}}
  end

  def teardown
    Timecop.return
  end

  def test_city_pollutants_aqi_no_values
    # skip
    stations_pollutants = { "vijecnica" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "bjelave" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "embassy" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "otoka" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil },
                            "ilidza" => { :so2 => nil, :no2 => nil, :co => nil, :o3 => nil, :pm10 => nil, :pm2_5 => nil, :pm => nil, :aqi => nil } }


    @script.expects(:stations_pollutants_aqi_data).returns(stations_pollutants)
    result = @script.city_pollutants_aqi
    
    assert_equal(result[:value],  0)
    assert_nil(result[:class])
  end

  def test_city_pollutants_aqi
    # skip
    @script.expects(:stations_pollutants_aqi_data).returns(@stations_pollutants)
    result = @script.city_pollutants_aqi

    assert_equal(result[:value],  3)
    assert_equal(result[:class],  :moderate_eea)
  end

end


