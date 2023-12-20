require_relative '../test_helper'

class WeatherClientTest < Minitest::Test
  def setup 
    @client = WeatherAir::WeatherClient.new
  end

  def test_current_weather_data
    response = '{ "coord": {"lon": 18.3867, "lat": 43.852},
              "weather": [{"id": 741, "main": "Fog", "description": "fog", "icon": "50n"}],
              "base": "stations",
              "main": {"temp": -3.12, "feels_like": -3.12, "temp_min": -3.12, "temp_max": -3.12, "pressure": 1023, "humidity": 100},
              "visibility": 100,
              "wind": {"speed": 0.51, "deg": 0},
              "clouds": {"all": 75},
              "dt": 1703017565,
              "sys": {"type": 1, "id": 6906, "country": "BA", "sunrise": 1702966568, "sunset": 1702998632},
              "timezone": 3600,
              "id": 3268175,
              "name": "Hrasno",
              "cod": 200}'
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric").
      with(headers: { 'Content-Type'=>'application/json' }).
      to_return(status: 200, body: response, headers: { 'Content-Type'=>'application/json' })

    sarajevo_current_weather = @client.current_weather_data
    expected = {currenttemp: -3, feelslike: -3, humidity: 100, description: "fog", icon: "50n", rain: 0, wind: 0.51, sunrise: "07:16", sunset: "16:10"}
    assert_equal(expected, sarajevo_current_weather)
  end

  def test_current_weather_data_no_data
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric").
      with(headers: { 'Content-Type'=>'application/json' }).
      to_return(status: 404, body: "", headers: { 'Content-Type'=>'application/json' })

    sarajevo_current_weather = @client.current_weather_data
    expected = { error: "No current weather data available!" }
    assert_equal(expected, sarajevo_current_weather)
  end

  def test_weather_forecast_data
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric").
      with(headers: {'Content-Type'=>'application/json'}).
      to_return(status: 200, body: File.read('test/fixtures/weather_forecast_response.json'), headers: { 'Content-Type'=>'application/json' })

    sarajevo_weather_forecast = @client.weather_forecast_data
    expected = {"Wed 20.12."=>
                [{:description=>"scattered clouds", :icon=>"03n", :temp=>-1, :rain=>0},
                {:description=>"scattered clouds", :icon=>"03n", :temp=>2, :rain=>0},
                {:description=>"few clouds", :icon=>"02n", :temp=>5, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04d", :temp=>9, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04d", :temp=>12, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04d", :temp=>8, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04n", :temp=>6, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04n", :temp=>5, :rain=>0}],
              "Thu 21.12."=>
                [{:description=>"overcast clouds", :icon=>"04n", :temp=>4, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04n", :temp=>4, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04n", :temp=>3, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04d", :temp=>5, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04d", :temp=>8, :rain=>0},
                {:description=>"few clouds", :icon=>"02d", :temp=>6, :rain=>0},
                {:description=>"scattered clouds", :icon=>"03n", :temp=>4, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04n", :temp=>5, :rain=>0}],
              "Fri 22.12."=>
                [{:description=>"overcast clouds", :icon=>"04n", :temp=>5, :rain=>0},
                {:description=>"overcast clouds", :icon=>"04n", :temp=>5, :rain=>0},
                {:description=>"broken clouds", :icon=>"04n", :temp=>5, :rain=>0},
                {:description=>"few clouds", :icon=>"02d", :temp=>8, :rain=>0},
                {:description=>"few clouds", :icon=>"02d", :temp=>10, :rain=>0},
                {:description=>"few clouds", :icon=>"02d", :temp=>7, :rain=>0},
                {:description=>"light rain", :icon=>"10n", :temp=>6, :rain=>0.28},
                {:description=>"light rain", :icon=>"10n", :temp=>5, :rain=>0.12}],
              "Sat 23.12."=>
                [{:description=>"broken clouds", :icon=>"04n", :temp=>5, :rain=>0},
                {:description=>"broken clouds", :icon=>"04n", :temp=>5, :rain=>0},
                {:description=>"broken clouds", :icon=>"04n", :temp=>4, :rain=>0},
                {:description=>"broken clouds", :icon=>"04d", :temp=>8, :rain=>0},
                {:description=>"broken clouds", :icon=>"04d", :temp=>11, :rain=>0},
                {:description=>"few clouds", :icon=>"02d", :temp=>8, :rain=>0},
                {:description=>"scattered clouds", :icon=>"03n", :temp=>6, :rain=>0},
                {:description=>"scattered clouds", :icon=>"03n", :temp=>6, :rain=>0}],
              "Sun 24.12."=>
                [{:description=>"scattered clouds", :icon=>"03n", :temp=>5, :rain=>0},
                {:description=>"broken clouds", :icon=>"04n", :temp=>5, :rain=>0},
                {:description=>"broken clouds", :icon=>"04n", :temp=>5, :rain=>0},
                {:description=>"few clouds", :icon=>"02d", :temp=>9, :rain=>0},
                {:description=>"few clouds", :icon=>"02d", :temp=>12, :rain=>0},
                {:description=>"scattered clouds", :icon=>"03d", :temp=>9, :rain=>0},
                {:description=>"scattered clouds", :icon=>"03n", :temp=>7, :rain=>0},
                {:description=>"few clouds", :icon=>"02n", :temp=>7, :rain=>0}]}

    assert_equal(expected, sarajevo_weather_forecast)
  end

  def test_weather_forecast_data_no_data
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric").
      with(headers: {'Content-Type'=>'application/json'}).
      to_return(status: 403, body: "", headers: { 'Content-Type'=>'application/json' })

    sarajevo_weather_forecast = @client.weather_forecast_data
    expected = { error: 'No weather forecast data available!' }
    assert_equal(expected, sarajevo_weather_forecast)
  end

end