require_relative '../test_helper'

class WeatherClientTest < Minitest::Test
  def setup 
    @client = WeatherAir::WeatherClient.new
    I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
    I18n.config.available_locales = %i[en bs]
  end

  def teardown
    Timecop.return
    I18n.locale = :en
  end

  def test_owm_sunrise_sunset
    response = '{ "coord": {"lon": 18.3867, "lat": 43.852 },
                  "weather": [{"id": 741, "main": "Fog", "description": "fog", "icon": "50n"}],
                  "base": "stations",
                  "main": {"temp": -3.12, "feels_like": -3.12, "temp_min": -3.12, "temp_max": -3.12, "pressure": 1023, "humidity": 100 },
                  "visibility": 100,
                  "wind": {"speed": 0.51, "deg": 0 },
                  "clouds": {"all": 75 },
                  "dt": 1703017565,
                  "sys": {"type": 1, "id": 6906, "country": "BA", "sunrise": 1702966568, "sunset": 1702998632 },
                  "timezone": 3600,
                  "id": 3268175,
                  "name": "Hrasno",
                  "cod": 200}'
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric").
      with(headers: { 'Content-Type'=>'application/json' }).
      to_return(status: 200, body: response, headers: { 'Content-Type'=>'application/json' })

    sarajevo_current_weather = @client.owm_sunrise_sunset
    expected = {:sunrise => "07:16 am", :sunset => "04:10 pm"}
    assert_equal(expected, sarajevo_current_weather)
  end

  def test_owm_sunrise_sunset_bs_locale
    response = '{
                  "coord": {
                    "lon": 18.3867,
                    "lat": 43.852
                  },
                  "weather": [
                    {
                      "id": 800,
                      "main": "Clear",
                      "description": "vedro",
                      "icon": "01d"
                    }
                  ],
                  "base": "stations",
                  "main": {
                    "temp": 19.88,
                    "feels_like": 18.76,
                    "temp_min": 19.88,
                    "temp_max": 19.88,
                    "pressure": 1018,
                    "humidity": 32
                  },
                  "visibility": 10000,
                  "wind": {
                    "speed": 1.54,
                    "deg": 0
                  },
                  "clouds": {
                    "all": 0
                  },
                  "dt": 1712231102,
                  "sys": {
                    "type": 2,
                    "id": 145110,
                    "country": "BA",
                    "sunrise": 1712204517,
                    "sunset": 1712250982
                  },
                  "timezone": 7200,
                  "id": 3268175,
                  "name": "Hrasno",
                  "cod": 200
                }'
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric&lang=hr").
      with(headers: { 'Content-Type'=>'application/json' }).
      to_return(status: 200, body: response, headers: { 'Content-Type'=>'application/json' })
    
    I18n.locale = :bs
    sarajevo_current_weather = @client.owm_sunrise_sunset
    expected = {:sunrise => "05:21", :sunset => "18:16"}
    assert_equal(expected, sarajevo_current_weather)
  end

  def test_owm_sunrise_sunset_no_data
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric").
      with(headers: { 'Content-Type'=>'application/json' }).
      to_return(status: 404, body: "", headers: { 'Content-Type'=>'application/json' })

    Sentry.expects(:capture_exception)
    sarajevo_current_weather = @client.owm_sunrise_sunset
    expected = { error: { en: 'Error: No current sunrise/sunset data available! Please visit openweathermap.org for more information.', 
                          bs: 'Greška: Nedostupni podaci o izlasku/zalasku sunca! Posjetite openweathermap.org za više informacija.' } }
    assert_equal(expected, sarajevo_current_weather)
  end

  def test_owm_weather_forecast
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric").
      with(headers: {'Content-Type'=>'application/json'}).
      to_return(status: 200, body: File.read('test/fixtures/owm_weather_forecast_response.json'), headers: { 'Content-Type'=>'application/json' })
    
    Timecop.freeze(Time.local(2023, 12, 20, 14, 30, 0))

    sarajevo_weather_forecast = @client.owm_weather_forecast
    expected =  { "Thursday 21.12." =>
                   [ { :description => "overcast clouds", :icon => "04n", :temp => 4, :rain => 0 },
                     { :description => "overcast clouds", :icon => "04n", :temp => 4, :rain => 0 },
                     { :description => "overcast clouds", :icon => "04n", :temp => 3, :rain => 0 },
                     { :description => "overcast clouds", :icon => "04d", :temp => 5, :rain => 0 },
                     { :description => "overcast clouds", :icon => "04d", :temp => 8, :rain => 0 },
                     { :description => "few clouds", :icon => "02d", :temp => 6, :rain => 0 },
                     { :description => "scattered clouds", :icon => "03n", :temp => 4, :rain => 0 },
                     { :description => "overcast clouds", :icon => "04n", :temp => 5, :rain => 0 } ],
                  "Friday 22.12." =>
                   [ { :description => "overcast clouds", :icon => "04n", :temp => 5, :rain => 0 },
                     { :description => "overcast clouds", :icon => "04n", :temp => 5, :rain => 0 },
                     { :description => "broken clouds", :icon => "04n", :temp => 5, :rain => 0 },
                     { :description => "few clouds", :icon => "02d", :temp => 8, :rain => 0 },
                     { :description => "few clouds", :icon => "02d", :temp => 10, :rain => 0 },
                     { :description => "few clouds", :icon => "02d", :temp => 7, :rain => 0 },
                     { :description => "light rain", :icon => "10n", :temp => 6, :rain => 0.28 },
                     { :description => "light rain", :icon => "10n", :temp => 5, :rain => 0.12 } ],
                  "Saturday 23.12." =>
                   [ { :description => "broken clouds", :icon => "04n", :temp => 5, :rain => 0 },
                     { :description => "broken clouds", :icon => "04n", :temp => 5, :rain => 0 },
                     { :description => "broken clouds", :icon => "04n", :temp => 4, :rain => 0 },
                     { :description => "broken clouds", :icon => "04d", :temp => 8, :rain => 0 },
                     { :description => "broken clouds", :icon => "04d", :temp => 11, :rain => 0 },
                     { :description => "few clouds", :icon => "02d", :temp => 8, :rain => 0 },
                     { :description => "scattered clouds", :icon => "03n", :temp => 6, :rain => 0 },
                     { :description => "scattered clouds", :icon => "03n", :temp => 6, :rain => 0 } ],
                  "Sunday 24.12." =>
                   [ { :description => "scattered clouds", :icon => "03n", :temp => 5, :rain => 0 },
                     { :description => "broken clouds", :icon => "04n", :temp => 5, :rain => 0 },
                     { :description => "broken clouds", :icon => "04n", :temp => 5, :rain => 0 },
                     { :description => "few clouds", :icon => "02d", :temp => 9, :rain => 0 },
                     { :description => "few clouds", :icon => "02d", :temp => 12, :rain => 0 },
                     { :description => "scattered clouds", :icon => "03d", :temp => 9, :rain => 0 },
                     { :description => "scattered clouds", :icon => "03n", :temp => 7, :rain => 0 },
                     { :description => "few clouds", :icon => "02n", :temp => 7, :rain => 0 } ] }

    assert_equal(expected, sarajevo_weather_forecast)
  end

  def test_owm_weather_forecast_bs_locale
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric&lang=hr").
      with(headers: {'Content-Type'=>'application/json'}).
      to_return(status: 200, body: File.read('test/fixtures/owm_weather_forecast_response_bs_locale.json'), headers: { 'Content-Type'=>'application/json' })
    
    Timecop.freeze(Time.local(2023, 4, 4, 14, 00, 0))
    I18n.locale = :bs
    sarajevo_weather_forecast = @client.owm_weather_forecast
    expected =  {"četvrtak 04.04."=>
                [{:description=>"vedro", :icon=>"01d", :temp=>18, :rain=>0}, 
                  {:description=>"blaga naoblaka", :icon=>"02n", :temp=>14, :rain=>0}, 
                  {:description=>"raštrkani oblaci", :icon=>"03n", :temp=>9, :rain=>0}],
                "petak 05.04."=>
                [{:description=>"isprekidani oblaci", :icon=>"04n", :temp=>8, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>7, :rain=>0},
                  {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>10, :rain=>0},
                  {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>16, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04d", :temp=>18, :rain=>0},
                  {:description=>"oblačno", :icon=>"04d", :temp=>17, :rain=>0},
                  {:description=>"oblačno", :icon=>"04n", :temp=>12, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>10, :rain=>0}],
                "subota 06.04."=>
                [{:description=>"raštrkani oblaci", :icon=>"03n", :temp=>9, :rain=>0},
                  {:description=>"oblačno", :icon=>"04n", :temp=>9, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04d", :temp=>12, :rain=>0},
                  {:description=>"oblačno", :icon=>"04d", :temp=>19, :rain=>0},
                  {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>22, :rain=>0},
                  {:description=>"vedro", :icon=>"01d", :temp=>21, :rain=>0},
                  {:description=>"vedro", :icon=>"01n", :temp=>15, :rain=>0},
                  {:description=>"vedro", :icon=>"01n", :temp=>13, :rain=>0}],
                "nedjelja 07.04."=>
                [{:description=>"blaga naoblaka", :icon=>"02n", :temp=>12, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>11, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04d", :temp=>14, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04d", :temp=>20, :rain=>0},
                  {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>22, :rain=>0},
                  {:description=>"vedro", :icon=>"01d", :temp=>21, :rain=>0},
                  {:description=>"raštrkani oblaci", :icon=>"03n", :temp=>15, :rain=>0},
                  {:description=>"blaga naoblaka", :icon=>"02n", :temp=>13, :rain=>0}],
                "ponedjeljak 08.04."=>
                [{:description=>"blaga naoblaka", :icon=>"02n", :temp=>12, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>11, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04d", :temp=>14, :rain=>0},
                  {:description=>"blaga naoblaka", :icon=>"02d", :temp=>21, :rain=>0},
                  {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>24, :rain=>0},
                  {:description=>"oblačno", :icon=>"04d", :temp=>23, :rain=>0},
                  {:description=>"oblačno", :icon=>"04n", :temp=>16, :rain=>0},
                  {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>14, :rain=>0}],
                "utorak 09.04."=>
                [{:description=>"oblačno", :icon=>"04n", :temp=>12, :rain=>0}, 
                {:description=>"oblačno", :icon=>"04n", :temp=>12, :rain=>0}, 
                {:description=>"oblačno", :icon=>"04d", :temp=>14, :rain=>0}, 
                {:description=>"oblačno", :icon=>"04d", :temp=>20, :rain=>0}, 
                {:description=>"oblačno", :icon=>"04d", :temp=>22, :rain=>0}]}

    assert_equal(expected, sarajevo_weather_forecast)
  end

  def test_owm_weather_forecast_no_data
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast?appid=#{ENV['API_KEY']}&lat=43.8519774&lon=18.3866868&units=metric").
      with(headers: {'Content-Type'=>'application/json'}).
      to_return(status: 403, body: "", headers: { 'Content-Type'=>'application/json' })

    Sentry.expects(:capture_exception)
    sarajevo_weather_forecast = @client.owm_weather_forecast
    expected = { error: { en: 'Error: No weather forecast data available! Please visit openweathermap.org for more information.', 
                          bs: 'Greška: Nedostupni podaci o vremenskoj prognozi! Posjetite openweathermap.org za više informacija.' } }
    assert_equal(expected, sarajevo_weather_forecast)
  end

  def test_meteoalarms
    Timecop.freeze(Time.local(2024, 2, 10, 12, 30, 0))

    stub_request(:get, "https://feeds.meteoalarm.org/api/v1/warnings/feeds-bosnia-herzegovina").
      to_return(status: 200, body: YAML.load(File.read("test/fixtures/duplicate_meteoalarms.yml")).to_json, headers: { 'Content-Type'=>'application/json' })

    expected_current_alarms = [{:alert=>
                                {:identifier=>"2.49.0.0.70.0.BA.240210074143.65630350",
                                :incidents=>"Alert",
                                :info=>
                                  {:en=>
                                    {:area=>[{:areaDesc=>"Sarajevo", :geocode=>[{:value=>"BA006", :valueName=>"EMMA_ID"}]}],
                                    :category=>["Met"],
                                    :certainty=>"Likely",
                                    :description=>"Gusts of southerly wind at a speed of 45-65 km/h.",
                                    :effective=>"2024-02-10T07:41:43+01:00",
                                    :event=>"Wind Orange Warning",
                                    :expires=>"2024-02-10T23:59:59+01:00",
                                    :headline=>"Wind Orange Warning for Bosnia and Herzegovina - region Sarajevo",
                                    :instruction=>"Be prepared for interference, structural damage, and the risk of injury from uprooted trees and wind-borne debris. Interruptions in electricity supply are possible.",
                                    :language=>"en",
                                    :onset=>"2024-02-10T06:00:00+01:00",
                                    :parameter=>[{:value=>"3; orange; Severe", :valueName=>"awareness_level"}, {:value=>"1; Wind", :valueName=>"awareness_type"}],
                                    :responseType=>["Monitor"],
                                    :senderName=>"Hydrometeorological Institute of Federation of Bosnia and Herzegovina",
                                    :severity=>"Severe",
                                    :urgency=>"Future",
                                    :web=>"http://www.fhmzbih.gov.ba/latinica/"},
                                  :bs=>
                                    {:area=>[{:areaDesc=>"Sarajevo", :geocode=>[{:value=>"BA006", :valueName=>"EMMA_ID"}]}],
                                    :category=>["Met"],
                                    :certainty=>"Likely",
                                    :description=>"Udari vjetra južnog smjera brzine 45-65 km/h.",
                                    :effective=>"2024-02-10T07:41:43+01:00",
                                    :event=>"Vjetar Narandžasto Upozorenje",
                                    :expires=>"2024-02-10T23:59:59+01:00",
                                    :headline=>"Vjetar Narandžasto Upozorenje za Bosnu i Hercegovinu - region Sarajevo",
                                    :instruction=>"Budite spremni na smetnje, strukturalna oštećenja i rizik za povrede od iščupanih stabala i krhotina koje nosi vjetar. Prekidi u snadbijevanju električnom energijom su mogući.",
                                    :language=>"bs",
                                    :onset=>"2024-02-10T06:00:00+01:00",
                                    :parameter=>[{:value=>"3; orange; Severe", :valueName=>"awareness_level"}, {:value=>"1; Wind", :valueName=>"awareness_type"}],
                                    :responseType=>["Monitor"],
                                    :senderName=>"Federalni hidrometeorološki zavod Federacije Bosne i Hercegovine",
                                    :severity=>"Severe",
                                    :urgency=>"Future",
                                    :web=>"http://www.fhmzbih.gov.ba/latinica/"}},
                                :msgType=>"Alert",
                                :scope=>"Public",
                                :sender=>"sinoptika@fhmzbih.gov.ba",
                                :sent=>"2024-02-10T07:41:43+01:00",
                                :status=>"Actual"},
                              :uuid=>"3f1ce011-d0c1-4b45-bf54-1686a875a89d"},
                              {:alert=>
                                {:identifier=>"2.49.0.0.70.0.BA.240210074143.65630350",
                                :incidents=>"Alert",
                                :info=>
                                  {:en=>
                                    {:area=>[{:areaDesc=>"Sarajevo", :geocode=>[{:value=>"BA006", :valueName=>"EMMA_ID"}]}],
                                    :category=>["Met"],
                                    :certainty=>"Likely",
                                    :description=>"Fog.",
                                    :effective=>"2024-02-10T07:41:43+01:00",
                                    :event=>"Fog green warning",
                                    :expires=>"2024-02-10T23:59:59+01:00",
                                    :headline=>"Warning",
                                    :language=>"en",
                                    :onset=>"2024-02-10T06:00:00+01:00",
                                    :parameter=>[{:value=>"3; orange; Severe", :valueName=>"awareness_level"}, {:value=>"2; snow/ice", :valueName=>"awareness_type"}],
                                    :responseType=>["Monitor"],
                                    :senderName=>"Hydrometeorological Institute of Federation of Bosnia and Herzegovina",
                                    :severity=>"Moderate",
                                    :urgency=>"Future",
                                    :web=>"http://www.fhmzbih.gov.ba/latinica/"},
                                  :bs=>
                                    {:area=>[{:areaDesc=>"Sarajevo", :geocode=>[{:value=>"BA006", :valueName=>"EMMA_ID"}]}],
                                    :category=>["Met"],
                                    :certainty=>"Likely",
                                    :description=>"Magla zeleno upozorenje",
                                    :effective=>"2024-02-10T07:41:43+01:00",
                                    :event=>"Magla",
                                    :expires=>"2024-02-10T23:59:59+01:00",
                                    :headline=>"Upozorenje",
                                    :language=>"bs",
                                    :onset=>"2024-02-10T06:00:00+01:00",
                                    :parameter=>[{:value=>"3; orange; Severe", :valueName=>"awareness_level"}, {:value=>"2; snow/ice", :valueName=>"awareness_type"}],
                                    :responseType=>["Monitor"],
                                    :senderName=>"Federalni hidrometeorološki zavod Federacije Bosne i Hercegovine",
                                    :severity=>"Moderate",
                                    :urgency=>"Future",
                                    :web=>"http://www.fhmzbih.gov.ba/latinica/"}},
                                :msgType=>"Alert",
                                :scope=>"Public",
                                :sender=>"sinoptika@fhmzbih.gov.ba",
                                :sent=>"2024-02-10T07:41:43+01:00",
                                :status=>"Actual"},
                              :uuid=>"3f1ce011-d0c1-4b45-bf54-1686a875a89d"}]

    expected_future_alarms = [{:alert=>
                              {:identifier=>"2.49.0.0.70.0.BA.240210074143.65630350",
                                :incidents=>"Alert",
                                :info=>
                                {:en=>
                                  {:area=>[{:areaDesc=>"Sarajevo", :geocode=>[{:value=>"BA006", :valueName=>"EMMA_ID"}]}],
                                    :category=>["Met"],
                                    :certainty=>"Likely",
                                    :description=>"Gusts of southerly wind at a speed of 45-65 km/h.",
                                    :effective=>"2024-02-10T07:41:43+01:00",
                                    :event=>"Wind Yellow Warning",
                                    :expires=>"2024-02-11T23:59:59+01:00",
                                    :headline=>"Wind Yellow Warning for Bosnia and Herzegovina - region Sarajevo",
                                    :instruction=>"Be prepared for interference, structural damage, and the risk of injury from uprooted trees and wind-borne debris. Interruptions in electricity supply are possible.",
                                    :language=>"en",
                                    :onset=>"2024-02-11T06:00:00+01:00",
                                    :parameter=>[{:value=>"2; yellow; Moderate", :valueName=>"awareness_level"}, {:value=>"1; Wind", :valueName=>"awareness_type"}],
                                    :responseType=>["Monitor"],
                                    :senderName=>"Hydrometeorological Institute of Federation of Bosnia and Herzegovina",
                                    :severity=>"Moderate",
                                    :urgency=>"Future",
                                    :web=>"http://www.fhmzbih.gov.ba/latinica/"},
                                  :bs=>
                                  {:area=>[{:areaDesc=>"Sarajevo", :geocode=>[{:value=>"BA006", :valueName=>"EMMA_ID"}]}],
                                    :category=>["Met"],
                                    :certainty=>"Likely",
                                    :description=>"Udari vjetra južnog smjera brzine 45-65 km/h.",
                                    :effective=>"2024-02-10T07:41:43+01:00",
                                    :event=>"Vjetar žuto Upozorenje",
                                    :expires=>"2024-02-11T23:59:59+01:00",
                                    :headline=>"Vjetar žuto Upozorenje za Bosnu i Hercegovinu - region Sarajevo",
                                    :instruction=>"Budite spremni na smetnje, strukturalna oštećenja i rizik za povrede od iščupanih stabala i krhotina koje nosi vjetar. Prekidi u snadbijevanju električnom energijom su mogući.",
                                    :language=>"bs",
                                    :onset=>"2024-02-11T06:00:00+01:00",
                                    :parameter=>[{:value=>"2; yellow; Moderate", :valueName=>"awareness_level"}, {:value=>"1; Wind", :valueName=>"awareness_type"}],
                                    :responseType=>["Monitor"],
                                    :senderName=>"Federalni hidrometeorološki zavod Federacije Bosne i Hercegovine",
                                    :severity=>"Moderate",
                                    :urgency=>"Future",
                                    :web=>"http://www.fhmzbih.gov.ba/latinica/"}},
                                :msgType=>"Alert",
                                :scope=>"Public",
                                :sender=>"sinoptika@fhmzbih.gov.ba",
                                :sent=>"2024-02-10T07:41:43+01:00",
                                :status=>"Actual"},
                              :uuid=>"3f1ce011-d0c1-4b45-bf54-1686a875a89d",
                              :start_date=>"2024-02-11 06:00:00 +0100"},
                            {:alert=>
                              {:identifier=>"2.49.0.0.70.0.BA.240210074143.65630350",
                                :incidents=>"Alert",
                                :info=>
                                {:en=>
                                  {:area=>[{:areaDesc=>"Sarajevo", :geocode=>[{:value=>"BA006", :valueName=>"EMMA_ID"}]}],
                                    :category=>["Met"],
                                    :certainty=>"Likely",
                                    :description=>"Fog.",
                                    :effective=>"2024-02-10T07:41:43+01:00",
                                    :event=>"Fog green warning",
                                    :expires=>"2024-02-12T23:59:59+01:00",
                                    :headline=>"Warning",
                                    :language=>"en",
                                    :onset=>"2024-02-12T06:00:00+01:00",
                                    :parameter=>[{:value=>"3; orange; Severe", :valueName=>"awareness_level"}, {:value=>"2; snow/ice", :valueName=>"awareness_type"}],
                                    :responseType=>["Monitor"],
                                    :senderName=>"Hydrometeorological Institute of Federation of Bosnia and Herzegovina",
                                    :severity=>"Moderate",
                                    :urgency=>"Future",
                                    :web=>"http://www.fhmzbih.gov.ba/latinica/"},
                                  :bs=>
                                  {:area=>[{:areaDesc=>"Sarajevo", :geocode=>[{:value=>"BA006", :valueName=>"EMMA_ID"}]}],
                                    :category=>["Met"],
                                    :certainty=>"Likely",
                                    :description=>"Magla zeleno upozorenje",
                                    :effective=>"2024-02-10T07:41:43+01:00",
                                    :event=>"Magla",
                                    :expires=>"2024-02-12T23:59:59+01:00",
                                    :headline=>"Upozorenje",
                                    :language=>"bs",
                                    :onset=>"2024-02-12T06:00:00+01:00",
                                    :parameter=>[{:value=>"3; orange; Severe", :valueName=>"awareness_level"}, {:value=>"2; snow/ice", :valueName=>"awareness_type"}],
                                    :responseType=>["Monitor"],
                                    :senderName=>"Federalni hidrometeorološki zavod Federacije Bosne i Hercegovine",
                                    :severity=>"Moderate",
                                    :urgency=>"Future",
                                    :web=>"http://www.fhmzbih.gov.ba/latinica/"}},
                                :msgType=>"Alert",
                                :scope=>"Public",
                                :sender=>"sinoptika@fhmzbih.gov.ba",
                                :sent=>"2024-02-10T07:41:43+01:00",
                                :status=>"Actual"},
                              :uuid=>"3f1ce011-d0c1-4b45-bf54-1686a875a89d",
                              :start_date=>"2024-02-12 06:00:00 +0100"}]
 
    (current_alarms, future_alarms) = @client.meteoalarms  
    assert_equal(expected_current_alarms, current_alarms)
    assert_equal(expected_future_alarms, future_alarms)
  end

  def test_meteoalarms_no_data
    Timecop.freeze(Time.local(2024, 2, 10, 12, 30, 0))

    stub_request(:get, "https://feeds.meteoalarm.org/api/v1/warnings/feeds-bosnia-herzegovina").
      to_return(status: 403, body: "", headers: { 'Content-Type'=>'application/json' })
    
    (current_alarms, future_alarms) = @client.meteoalarms  
    expected_no_current_alarms = { :error => { :en=>"Error: No current meteoalarms data available! Please visit meteoalarm.org for more information.", 
                                               :bs=>"Greška: Nedostupni podaci o trenutnim meteoalarmima! Posjetite meteoalarm.org za više informacija." } }
    expected_no_future_alarms = { :error => { :en=>"Error: No future meteoalarms data available! Please visit meteoalarm.org for more information.", 
                                               :bs=>"Greška: Nedostupni podaci o nadolazeċim meteoalarmima! Posjetite meteoalarm.org za više informacija." } }

    assert_equal(expected_no_current_alarms, current_alarms)
    assert_equal(expected_no_future_alarms, future_alarms)                                          
  end

  def test_yr_weather
    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=520&lat=43.8519&lon=18.3866").
      to_return(status: 200, body: File.read("test/fixtures/yr_sarajevo_response.json"), headers: {'Content-Type'=>'application/json'})
    
    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=1100&lat=43.8383&lon=18.4498").
      to_return(status: 200, body: File.read("test/fixtures/yr_trebevic_response.json"), headers: {'Content-Type'=>'application/json'}) 

    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=1200&lat=43.7507&lon=18.2632").
      to_return(status: 200, body: File.read("test/fixtures/yr_igman_response.json"), headers: {'Content-Type'=>'application/json'})
    
    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=1287&lat=43.7163&lon=18.287").
      to_return(status: 200, body: File.read("test/fixtures/yr_bjelasnica_response.json"), headers: {'Content-Type'=>'application/json'})

    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=1557&lat=43.7383&lon=18.5645").
      to_return(status: 200, body: File.read("test/fixtures/yr_jahorina_response.json"), headers: {'Content-Type'=>'application/json'})  

    result = @client.yr_weather
    assert(result[:bjelasnica][:forecast][0][:air_temperature], 10)
  end

  def test_yr_weather_no_data
    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=520&lat=43.8519&lon=18.3866").
      to_return(status: 200, body: File.read("test/fixtures/yr_sarajevo_response.json"), headers: {'Content-Type'=>'application/json'})
    
    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=1100&lat=43.8383&lon=18.4498").
      to_return(status: 200, body: File.read("test/fixtures/yr_trebevic_response.json"), headers: {'Content-Type'=>'application/json'}) 

    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=1200&lat=43.7507&lon=18.2632").
      to_return(status: 403, body: "", headers: {'Content-Type'=>'application/json'})
    
    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=1287&lat=43.7163&lon=18.287").
      to_return(status: 200, body: File.read("test/fixtures/yr_bjelasnica_response.json"), headers: {'Content-Type'=>'application/json'})

    stub_request(:get, "https://api.met.no/weatherapi/locationforecast/2.0/complete.json?altitude=1557&lat=43.7383&lon=18.5645").
      to_return(status: 200, body: File.read("test/fixtures/yr_jahorina_response.json"), headers: {'Content-Type'=>'application/json'})  

    Sentry.expects(:capture_exception)
    result = @client.yr_weather
    expected = { :error=> { :en=>"Error: No weather forecast data available for this location! Please visit yr.no for more information.", 
                            :bs=>"Greška: Nedostupni podaci o vremenskoj prognozi za ovu lokaciju! Posjetite yr.no za više informacija." } }
    
    assert_equal(expected, result[:igman][:forecast])
  end

end