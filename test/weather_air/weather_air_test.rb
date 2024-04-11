require_relative '../test_helper'

class WeatherAirTest < TestCase
  def setup 
    super
  end

  def test_run
    WeatherAir::WeatherClient.any_instance.stubs(:owm_sunrise_sunset).returns({:sunrise=>1712290810, :sunset=>1712337454})

    owm_weather_forecast_data = YAML.load(File.read("test/fixtures/owm_weather_forecast_data.yml"), permitted_classes: [Symbol])
    owm_weather_forecast_data_bs = YAML.load(File.read("test/fixtures/owm_weather_forecast_data_bs.yml"), permitted_classes: [Symbol])
    WeatherAir::WeatherClient.any_instance.stubs(:owm_weather_forecast).returns(owm_weather_forecast_data)
    WeatherAir::WeatherClient.any_instance.stubs(:owm_weather_forecast).returns(owm_weather_forecast_data_bs)

    yr_weather_data = YAML.load(File.read("test/fixtures/yr_weather_data.yml"), permitted_classes: [Time, Symbol])
    WeatherAir::WeatherClient.any_instance.stubs(:yr_weather_forecast).returns(yr_weather_data)

    WeatherAir::WeatherClient.any_instance.stubs(:meteoalarms).returns([[], []])

    WeatherAir::AirQualityIndex.any_instance.stubs(:city_pollutants_aqi).returns({:so2=>1, :no2=>1, :o3=>4, :pm10=>2, :pm25=>1, :value=>4, :class=>:poor_eea})
    
    stations_pollutants_aqi_data = YAML.load(File.read("test/fixtures/stations_pollutants_aqi_data.yml"), permitted_classes: [Symbol])
    WeatherAir::AirQualityIndex.any_instance.stubs(:stations_pollutants_aqi_data).returns(stations_pollutants_aqi_data)
    
    ks_aqi_data = YAML.load(File.read("test/fixtures/ks_aqi_data.yml"), permitted_classes: [Time, Symbol])
    WeatherAir::AirQualityIndex.any_instance.stubs(:aqi_by_ks).returns(ks_aqi_data)
    
    eko_akcija_aqi_data = [[["Ambasada SAD", "", "14", "", "60", "Umjereno zagađen"],
                            ["Vijećnica", "10", "9", "1", "42", "Dobar"],
                            ["Otoka", "10", "4", "8", "21", "Dobar"],
                            ["Bjelave", "11", "4", "7", "17", "Dobar"],
                            ["Ilidža", "6", "3", "3", "13", "Dobar"]],
                           60,
                           "moderate"]                    
    WeatherAir::AirQualityIndex.any_instance.stubs(:aqi_by_ekoakcija).returns(eko_akcija_aqi_data)

    assert_equal(5, WeatherAir.run.length)
  end

  def test_run_error
    WeatherAir::WeatherClient.expects(:new).raises(StandardError)
    ExceptionNotifier.expects(:notify)
    WeatherAir.run
  end

  def test_text_to_class
    assert_equal("good", WeatherAir.text_to_class("Dobar"))
    assert_equal("moderate", WeatherAir.text_to_class("Umjereno zagađen"))
    assert_equal("unhealthy_for_sensitive_groups", WeatherAir.text_to_class("Nezdrav za osjetljive grupe"))
    assert_equal("unhealthy", WeatherAir.text_to_class("Nezdrav"))
    assert_equal("very_unhealthy", WeatherAir.text_to_class("Vrlo nezdrav"))
    assert_equal("hazardous", WeatherAir.text_to_class("Opasan"))
  end

  def test_icon_path
    assert_equal("../yr_icons/image.svg", WeatherAir.icon_path("image"))
    I18n.locale = :bs
    assert_equal("yr_icons/image.svg", WeatherAir.icon_path("image"))
  end

  def test_last_update
    Timecop.freeze(Time.local(2024, 4, 5, 13, 0, 0))
    assert_equal("Friday (April 05, 2024) 01:00 pm", WeatherAir.last_update)
  end

  def test_utc_to_datetime
    assert_equal("07:16 am", WeatherAir.utc_to_datetime(1702966568))
  end

end