require_relative '../test_helper'

class WeatherAirTest < TestCase
  def setup 
    super
  end

  def test_run
    yr_weather_data = {:sarajevo=>
    {:name=>"Sarajevo",
     :lat=>43.8519,
     :lon=>18.3866,
     :altitude=>520,
     :forecast=>
      [{:time=>'2024-04-05 16:00:00 +0200', :air_temperature=>20, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>36.7, :uv_index=>2.1, :wind_from_direction=>252.8, :wind_speed=>3.3, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-05 17:00:00 +0200', :air_temperature=>20, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>39.8, :uv_index=>0.9, :wind_from_direction=>260.4, :wind_speed=>2.2, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 18:00:00 +0200', :air_temperature=>19, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>56.3, :uv_index=>0.3, :wind_from_direction=>297.8, :wind_speed=>1.2, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 19:00:00 +0200', :air_temperature=>18, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>44.8, :uv_index=>0.0, :wind_from_direction=>24.4, :wind_speed=>1.8, :uv_class=>nil},
       {:time=>'2024-04-05 20:00:00 +0200', :air_temperature=>14, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>55.6, :uv_index=>0.0, :wind_from_direction=>99.3, :wind_speed=>1.2, :uv_class=>nil},
       {:time=>'2024-04-05 21:00:00 +0200', :air_temperature=>12, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>62.5, :uv_index=>0.0, :wind_from_direction=>130.5, :wind_speed=>2.3, :uv_class=>nil},
       {:time=>'2024-04-05 22:00:00 +0200', :air_temperature=>11, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>66.5, :uv_index=>0.0, :wind_from_direction=>114.2, :wind_speed=>2.5, :uv_class=>nil},
       {:time=>'2024-04-05 23:00:00 +0200', :air_temperature=>10, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>70.9, :uv_index=>0.0, :wind_from_direction=>91.8, :wind_speed=>2.3, :uv_class=>nil},
       {:time=>'2024-04-06 00:00:00 +0200', :air_temperature=>10, :icon=>"fair_night", :precipitation_amount=>0.0, :relative_humidity=>70.3, :uv_index=>0.0, :wind_from_direction=>102.6, :wind_speed=>2.0, :uv_class=>nil},
       {:time=>'2024-04-06 01:00:00 +0200', :air_temperature=>9, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>71.6, :uv_index=>0.0, :wind_from_direction=>101.8, :wind_speed=>1.6, :uv_class=>nil},
       {:time=>'2024-04-06 02:00:00 +0200', :air_temperature=>9, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>75.0, :uv_index=>0.0, :wind_from_direction=>102.5, :wind_speed=>1.2, :uv_class=>nil},
       {:time=>'2024-04-06 03:00:00 +0200', :air_temperature=>9, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>77.0, :uv_index=>0.0, :wind_from_direction=>103.5, :wind_speed=>1.3, :uv_class=>nil},
       {:time=>'2024-04-06 04:00:00 +0200', :air_temperature=>8, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>79.8, :uv_index=>0.0, :wind_from_direction=>102.3, :wind_speed=>1.3, :uv_class=>nil},
       {:time=>'2024-04-06 05:00:00 +0200', :air_temperature=>9, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>78.6, :uv_index=>0.0, :wind_from_direction=>99.2, :wind_speed=>1.5, :uv_class=>nil},
       {:time=>'2024-04-06 06:00:00 +0200', :air_temperature=>8, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>81.2, :uv_index=>0.0, :wind_from_direction=>96.9, :wind_speed=>1.3, :uv_class=>nil},
       {:time=>'2024-04-06 07:00:00 +0200', :air_temperature=>9, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>79.2, :uv_index=>0.2, :wind_from_direction=>90.5, :wind_speed=>1.0, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 08:00:00 +0200', :air_temperature=>12, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>79.5, :uv_index=>0.7, :wind_from_direction=>106.7, :wind_speed=>1.0, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 09:00:00 +0200', :air_temperature=>14, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>65.9, :uv_index=>1.7, :wind_from_direction=>291.1, :wind_speed=>1.0, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 10:00:00 +0200', :air_temperature=>16, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>60.1, :uv_index=>3.0, :wind_from_direction=>246.3, :wind_speed=>1.6, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 11:00:00 +0200', :air_temperature=>18, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>51.7, :uv_index=>4.3, :wind_from_direction=>297.4, :wind_speed=>1.5, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 12:00:00 +0200', :air_temperature=>20, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>43.4, :uv_index=>5.1, :wind_from_direction=>252.7, :wind_speed=>2.0, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 13:00:00 +0200', :air_temperature=>21, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>40.4, :uv_index=>5.3, :wind_from_direction=>261.1, :wind_speed=>2.3, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 14:00:00 +0200', :air_temperature=>22, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>41.0, :uv_index=>4.7, :wind_from_direction=>295.8, :wind_speed=>2.2, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 15:00:00 +0200', :air_temperature=>22, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>38.2, :uv_index=>3.5, :wind_from_direction=>301.0, :wind_speed=>2.6, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 16:00:00 +0200', :air_temperature=>23, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>36.8, :uv_index=>2.1, :wind_from_direction=>308.7, :wind_speed=>2.4, :uv_class=>"uv_moderate"}]},
   :trebevic=>
    {:name=>"Trebević",
     :lat=>43.8383,
     :lon=>18.4498,
     :altitude=>1100,
     :forecast=>
      [{:time=>'2024-04-05 16:00:00 +0200', :air_temperature=>16, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>40.7, :uv_index=>2.2, :wind_from_direction=>316.9, :wind_speed=>3.3, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-05 17:00:00 +0200', :air_temperature=>16, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>39.6, :uv_index=>1.0, :wind_from_direction=>299.1, :wind_speed=>2.3, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 18:00:00 +0200', :air_temperature=>16, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>49.3, :uv_index=>0.3, :wind_from_direction=>313.4, :wind_speed=>1.3, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 19:00:00 +0200', :air_temperature=>15, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>40.1, :uv_index=>0.0, :wind_from_direction=>75.7, :wind_speed=>1.8, :uv_class=>nil},
       {:time=>'2024-04-05 20:00:00 +0200', :air_temperature=>10, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>64.1, :uv_index=>0.0, :wind_from_direction=>156.0, :wind_speed=>1.8, :uv_class=>nil},
       {:time=>'2024-04-05 21:00:00 +0200', :air_temperature=>9, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>68.9, :uv_index=>0.0, :wind_from_direction=>170.3, :wind_speed=>2.3, :uv_class=>nil},
       {:time=>'2024-04-05 22:00:00 +0200', :air_temperature=>8, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>76.8, :uv_index=>0.0, :wind_from_direction=>161.3, :wind_speed=>2.5, :uv_class=>nil},
       {:time=>'2024-04-05 23:00:00 +0200', :air_temperature=>7, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>83.1, :uv_index=>0.0, :wind_from_direction=>157.5, :wind_speed=>2.3, :uv_class=>nil},
       {:time=>'2024-04-06 00:00:00 +0200', :air_temperature=>6, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>86.6, :uv_index=>0.0, :wind_from_direction=>151.8, :wind_speed=>2.0, :uv_class=>nil},
       {:time=>'2024-04-06 01:00:00 +0200', :air_temperature=>5, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>89.8, :uv_index=>0.0, :wind_from_direction=>149.0, :wind_speed=>1.5, :uv_class=>nil},
       {:time=>'2024-04-06 02:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>90.0, :uv_index=>0.0, :wind_from_direction=>148.1, :wind_speed=>1.1, :uv_class=>nil},
       {:time=>'2024-04-06 03:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>88.4, :uv_index=>0.0, :wind_from_direction=>146.0, :wind_speed=>1.3, :uv_class=>nil},
       {:time=>'2024-04-06 04:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>87.3, :uv_index=>0.0, :wind_from_direction=>148.3, :wind_speed=>1.3, :uv_class=>nil},
       {:time=>'2024-04-06 05:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>86.3, :uv_index=>0.0, :wind_from_direction=>144.7, :wind_speed=>1.4, :uv_class=>nil},
       {:time=>'2024-04-06 06:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>88.0, :uv_index=>0.0, :wind_from_direction=>148.4, :wind_speed=>1.5, :uv_class=>nil},
       {:time=>'2024-04-06 07:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>86.2, :uv_index=>0.2, :wind_from_direction=>146.9, :wind_speed=>1.3, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 08:00:00 +0200', :air_temperature=>8, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>81.8, :uv_index=>0.7, :wind_from_direction=>159.2, :wind_speed=>1.0, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 09:00:00 +0200', :air_temperature=>12, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>62.8, :uv_index=>1.7, :wind_from_direction=>337.5, :wind_speed=>0.8, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 10:00:00 +0200', :air_temperature=>14, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>59.6, :uv_index=>3.1, :wind_from_direction=>340.9, :wind_speed=>1.1, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 11:00:00 +0200', :air_temperature=>16, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>52.6, :uv_index=>4.5, :wind_from_direction=>355.7, :wind_speed=>1.5, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 12:00:00 +0200', :air_temperature=>17, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>47.3, :uv_index=>5.3, :wind_from_direction=>351.1, :wind_speed=>1.6, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 13:00:00 +0200', :air_temperature=>18, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>44.6, :uv_index=>5.4, :wind_from_direction=>341.7, :wind_speed=>2.1, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 14:00:00 +0200', :air_temperature=>19, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>44.1, :uv_index=>4.8, :wind_from_direction=>343.0, :wind_speed=>2.2, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 15:00:00 +0200', :air_temperature=>19, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>43.2, :uv_index=>3.6, :wind_from_direction=>339.2, :wind_speed=>2.6, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 16:00:00 +0200', :air_temperature=>19, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>41.0, :uv_index=>2.2, :wind_from_direction=>346.6, :wind_speed=>2.6, :uv_class=>"uv_moderate"}]},
   :igman=>
    {:name=>"Igman",
     :lat=>43.7507,
     :lon=>18.2632,
     :altitude=>1200,
     :forecast=>
      [{:time=>'2024-04-05 16:00:00 +0200', :air_temperature=>16, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>38.5, :uv_index=>2.1, :wind_from_direction=>329.5, :wind_speed=>1.9, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-05 17:00:00 +0200', :air_temperature=>16, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>39.1, :uv_index=>0.9, :wind_from_direction=>315.4, :wind_speed=>1.5, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 18:00:00 +0200', :air_temperature=>15, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>46.1, :uv_index=>0.3, :wind_from_direction=>330.1, :wind_speed=>1.1, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 19:00:00 +0200', :air_temperature=>15, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>42.1, :uv_index=>0.0, :wind_from_direction=>266.4, :wind_speed=>1.8, :uv_class=>nil},
       {:time=>'2024-04-05 20:00:00 +0200', :air_temperature=>10, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>62.6, :uv_index=>0.0, :wind_from_direction=>187.5, :wind_speed=>2.0, :uv_class=>nil},
       {:time=>'2024-04-05 21:00:00 +0200', :air_temperature=>8, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>74.3, :uv_index=>0.0, :wind_from_direction=>187.8, :wind_speed=>2.7, :uv_class=>nil},
       {:time=>'2024-04-05 22:00:00 +0200', :air_temperature=>7, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>81.9, :uv_index=>0.0, :wind_from_direction=>182.1, :wind_speed=>2.8, :uv_class=>nil},
       {:time=>'2024-04-05 23:00:00 +0200', :air_temperature=>6, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>86.3, :uv_index=>0.0, :wind_from_direction=>183.5, :wind_speed=>2.6, :uv_class=>nil},
       {:time=>'2024-04-06 00:00:00 +0200', :air_temperature=>5, :icon=>"fair_night", :precipitation_amount=>0.0, :relative_humidity=>89.3, :uv_index=>0.0, :wind_from_direction=>179.1, :wind_speed=>2.2, :uv_class=>nil},
       {:time=>'2024-04-06 01:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>92.1, :uv_index=>0.0, :wind_from_direction=>177.5, :wind_speed=>1.8, :uv_class=>nil},
       {:time=>'2024-04-06 02:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>92.3, :uv_index=>0.0, :wind_from_direction=>179.4, :wind_speed=>1.4, :uv_class=>nil},
       {:time=>'2024-04-06 03:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>91.0, :uv_index=>0.0, :wind_from_direction=>176.8, :wind_speed=>1.4, :uv_class=>nil},
       {:time=>'2024-04-06 04:00:00 +0200', :air_temperature=>4, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>89.6, :uv_index=>0.0, :wind_from_direction=>179.1, :wind_speed=>1.6, :uv_class=>nil},
       {:time=>'2024-04-06 05:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>88.7, :uv_index=>0.0, :wind_from_direction=>178.3, :wind_speed=>1.7, :uv_class=>nil},
       {:time=>'2024-04-06 06:00:00 +0200', :air_temperature=>3, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>90.1, :uv_index=>0.0, :wind_from_direction=>181.2, :wind_speed=>1.7, :uv_class=>nil},
       {:time=>'2024-04-06 07:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>88.5, :uv_index=>0.2, :wind_from_direction=>179.9, :wind_speed=>1.7, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 08:00:00 +0200', :air_temperature=>8, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>83.1, :uv_index=>0.7, :wind_from_direction=>187.9, :wind_speed=>1.2, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 09:00:00 +0200', :air_temperature=>11, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>63.9, :uv_index=>1.7, :wind_from_direction=>4.6, :wind_speed=>0.7, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 10:00:00 +0200', :air_temperature=>13, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>60.5, :uv_index=>3.0, :wind_from_direction=>12.6, :wind_speed=>1.0, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 11:00:00 +0200', :air_temperature=>15, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>55.7, :uv_index=>4.3, :wind_from_direction=>12.4, :wind_speed=>1.5, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 12:00:00 +0200', :air_temperature=>16, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>52.2, :uv_index=>5.1, :wind_from_direction=>13.3, :wind_speed=>1.5, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 13:00:00 +0200', :air_temperature=>18, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>48.6, :uv_index=>5.3, :wind_from_direction=>7.3, :wind_speed=>1.2, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 14:00:00 +0200', :air_temperature=>19, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>45.5, :uv_index=>4.7, :wind_from_direction=>358.7, :wind_speed=>1.7, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 15:00:00 +0200', :air_temperature=>19, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>43.4, :uv_index=>3.5, :wind_from_direction=>353.5, :wind_speed=>2.0, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 16:00:00 +0200', :air_temperature=>19, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>41.9, :uv_index=>2.1, :wind_from_direction=>357.7, :wind_speed=>2.0, :uv_class=>"uv_moderate"}]},
   :bjelasnica=>
    {:name=>"Bjelašnica",
     :lat=>43.7163,
     :lon=>18.287,
     :altitude=>1287,
     :forecast=>
      [{:time=>'2024-04-05 17:00:00 +0200', :air_temperature=>14, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>46.8, :uv_index=>1.0, :wind_from_direction=>250.3, :wind_speed=>2.2, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 18:00:00 +0200', :air_temperature=>13, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>56.8, :uv_index=>0.3, :wind_from_direction=>233.3, :wind_speed=>1.4, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 19:00:00 +0200', :air_temperature=>11, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>67.9, :uv_index=>0.0, :wind_from_direction=>203.6, :wind_speed=>1.6, :uv_class=>nil},
       {:time=>'2024-04-05 20:00:00 +0200', :air_temperature=>9, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>72.7, :uv_index=>0.0, :wind_from_direction=>197.4, :wind_speed=>2.0, :uv_class=>nil},
       {:time=>'2024-04-05 21:00:00 +0200', :air_temperature=>8, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>79.6, :uv_index=>0.0, :wind_from_direction=>205.1, :wind_speed=>2.7, :uv_class=>nil},
       {:time=>'2024-04-05 22:00:00 +0200', :air_temperature=>7, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>83.5, :uv_index=>0.0, :wind_from_direction=>200.1, :wind_speed=>2.8, :uv_class=>nil},
       {:time=>'2024-04-05 23:00:00 +0200', :air_temperature=>7, :icon=>"fair_night", :precipitation_amount=>0.0, :relative_humidity=>85.1, :uv_index=>0.0, :wind_from_direction=>207.9, :wind_speed=>2.6, :uv_class=>nil},
       {:time=>'2024-04-06 00:00:00 +0200', :air_temperature=>7, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>84.8, :uv_index=>0.0, :wind_from_direction=>202.7, :wind_speed=>2.2, :uv_class=>nil},
       {:time=>'2024-04-06 01:00:00 +0200', :air_temperature=>7, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>82.6, :uv_index=>0.0, :wind_from_direction=>203.0, :wind_speed=>1.8, :uv_class=>nil},
       {:time=>'2024-04-06 02:00:00 +0200', :air_temperature=>7, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>80.0, :uv_index=>0.0, :wind_from_direction=>207.5, :wind_speed=>1.4, :uv_class=>nil},
       {:time=>'2024-04-06 03:00:00 +0200', :air_temperature=>7, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>76.5, :uv_index=>0.0, :wind_from_direction=>204.3, :wind_speed=>1.4, :uv_class=>nil},
       {:time=>'2024-04-06 04:00:00 +0200', :air_temperature=>7, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>74.9, :uv_index=>0.0, :wind_from_direction=>205.2, :wind_speed=>1.6, :uv_class=>nil},
       {:time=>'2024-04-06 05:00:00 +0200', :air_temperature=>7, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>75.6, :uv_index=>0.0, :wind_from_direction=>199.8, :wind_speed=>1.7, :uv_class=>nil},
       {:time=>'2024-04-06 06:00:00 +0200', :air_temperature=>6, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>79.4, :uv_index=>0.0, :wind_from_direction=>201.2, :wind_speed=>1.7, :uv_class=>nil},
       {:time=>'2024-04-06 07:00:00 +0200', :air_temperature=>6, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>82.0, :uv_index=>0.2, :wind_from_direction=>203.1, :wind_speed=>1.7, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 08:00:00 +0200', :air_temperature=>9, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>79.1, :uv_index=>0.7, :wind_from_direction=>196.9, :wind_speed=>1.2, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 09:00:00 +0200', :air_temperature=>12, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>62.3, :uv_index=>1.7, :wind_from_direction=>244.2, :wind_speed=>0.9, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 10:00:00 +0200', :air_temperature=>14, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>55.1, :uv_index=>3.1, :wind_from_direction=>236.1, :wind_speed=>1.2, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 11:00:00 +0200', :air_temperature=>15, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>52.0, :uv_index=>4.5, :wind_from_direction=>306.5, :wind_speed=>1.5, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 12:00:00 +0200', :air_temperature=>16, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>50.8, :uv_index=>5.3, :wind_from_direction=>342.9, :wind_speed=>1.5, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 13:00:00 +0200', :air_temperature=>17, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>48.7, :uv_index=>5.4, :wind_from_direction=>278.7, :wind_speed=>1.5, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 14:00:00 +0200', :air_temperature=>18, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>47.5, :uv_index=>4.8, :wind_from_direction=>292.4, :wind_speed=>2.1, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 15:00:00 +0200', :air_temperature=>18, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>47.3, :uv_index=>3.6, :wind_from_direction=>321.9, :wind_speed=>2.1, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 16:00:00 +0200', :air_temperature=>18, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>46.7, :uv_index=>2.2, :wind_from_direction=>336.0, :wind_speed=>2.0, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 17:00:00 +0200', :air_temperature=>17, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>49.0, :uv_index=>1.0, :wind_from_direction=>4.4, :wind_speed=>2.1, :uv_class=>"uv_low"}]},
   :jahorina=>
    {:name=>"Jahorina",
     :lat=>43.7383,
     :lon=>18.5645,
     :altitude=>1557,
     :forecast=>
      [{:time=>'2024-04-05 16:00:00 +0200', :air_temperature=>14, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>39.1, :uv_index=>2.1, :wind_from_direction=>303.2, :wind_speed=>3.3, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-05 17:00:00 +0200', :air_temperature=>13, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>45.6, :uv_index=>0.9, :wind_from_direction=>313.3, :wind_speed=>2.9, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 18:00:00 +0200', :air_temperature=>12, :icon=>"cloudy", :precipitation_amount=>0.0, :relative_humidity=>50.3, :uv_index=>0.3, :wind_from_direction=>318.3, :wind_speed=>2.1, :uv_class=>"uv_low"},
       {:time=>'2024-04-05 19:00:00 +0200', :air_temperature=>9, :icon=>"fair_night", :precipitation_amount=>0.0, :relative_humidity=>67.8, :uv_index=>0.0, :wind_from_direction=>295.8, :wind_speed=>1.5, :uv_class=>nil},
       {:time=>'2024-04-05 20:00:00 +0200', :air_temperature=>7, :icon=>"clearsky_night", :precipitation_amount=>0.0, :relative_humidity=>67.6, :uv_index=>0.0, :wind_from_direction=>268.6, :wind_speed=>1.7, :uv_class=>nil},
       {:time=>'2024-04-05 21:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>77.2, :uv_index=>0.0, :wind_from_direction=>275.0, :wind_speed=>2.0, :uv_class=>nil},
       {:time=>'2024-04-05 22:00:00 +0200', :air_temperature=>3, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>82.4, :uv_index=>0.0, :wind_from_direction=>271.3, :wind_speed=>1.9, :uv_class=>nil},
       {:time=>'2024-04-05 23:00:00 +0200', :air_temperature=>3, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>85.7, :uv_index=>0.0, :wind_from_direction=>267.4, :wind_speed=>1.8, :uv_class=>nil},
       {:time=>'2024-04-06 00:00:00 +0200', :air_temperature=>2, :icon=>"fair_night", :precipitation_amount=>0.0, :relative_humidity=>86.6, :uv_index=>0.0, :wind_from_direction=>262.0, :wind_speed=>1.5, :uv_class=>nil},
       {:time=>'2024-04-06 01:00:00 +0200', :air_temperature=>3, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>83.1, :uv_index=>0.0, :wind_from_direction=>279.1, :wind_speed=>1.2, :uv_class=>nil},
       {:time=>'2024-04-06 02:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>75.3, :uv_index=>0.0, :wind_from_direction=>277.7, :wind_speed=>1.0, :uv_class=>nil},
       {:time=>'2024-04-06 03:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>72.8, :uv_index=>0.0, :wind_from_direction=>273.0, :wind_speed=>1.0, :uv_class=>nil},
       {:time=>'2024-04-06 04:00:00 +0200', :air_temperature=>3, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>77.9, :uv_index=>0.0, :wind_from_direction=>264.4, :wind_speed=>1.1, :uv_class=>nil},
       {:time=>'2024-04-06 05:00:00 +0200', :air_temperature=>5, :icon=>"partlycloudy_night", :precipitation_amount=>0.0, :relative_humidity=>70.3, :uv_index=>0.0, :wind_from_direction=>300.2, :wind_speed=>1.1, :uv_class=>nil},
       {:time=>'2024-04-06 06:00:00 +0200', :air_temperature=>4, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>70.8, :uv_index=>0.0, :wind_from_direction=>245.4, :wind_speed=>1.1, :uv_class=>nil},
       {:time=>'2024-04-06 07:00:00 +0200', :air_temperature=>5, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>70.2, :uv_index=>0.2, :wind_from_direction=>39.2, :wind_speed=>1.2, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 08:00:00 +0200', :air_temperature=>7, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>69.5, :uv_index=>0.7, :wind_from_direction=>268.7, :wind_speed=>1.2, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 09:00:00 +0200', :air_temperature=>11, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>56.5, :uv_index=>1.7, :wind_from_direction=>237.4, :wind_speed=>0.8, :uv_class=>"uv_low"},
       {:time=>'2024-04-06 10:00:00 +0200', :air_temperature=>13, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>50.1, :uv_index=>3.1, :wind_from_direction=>211.8, :wind_speed=>1.0, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 11:00:00 +0200', :air_temperature=>14, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>46.1, :uv_index=>4.5, :wind_from_direction=>210.4, :wind_speed=>1.2, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 12:00:00 +0200', :air_temperature=>15, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>43.7, :uv_index=>5.3, :wind_from_direction=>317.3, :wind_speed=>1.4, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 13:00:00 +0200', :air_temperature=>16, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>42.0, :uv_index=>5.4, :wind_from_direction=>260.4, :wind_speed=>1.6, :uv_class=>"uv_high"},
       {:time=>'2024-04-06 14:00:00 +0200', :air_temperature=>17, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>41.2, :uv_index=>4.8, :wind_from_direction=>284.4, :wind_speed=>2.1, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 15:00:00 +0200', :air_temperature=>17, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>40.6, :uv_index=>3.6, :wind_from_direction=>301.7, :wind_speed=>2.6, :uv_class=>"uv_moderate"},
       {:time=>'2024-04-06 16:00:00 +0200', :air_temperature=>17, :icon=>"partlycloudy_day", :precipitation_amount=>0.0, :relative_humidity=>39.8, :uv_index=>2.1, :wind_from_direction=>312.9, :wind_speed=>2.9, :uv_class=>"uv_moderate"}]}}
    WeatherAir::WeatherClient.any_instance.stubs(:owm_sunrise_sunset).returns({:sunrise=>1712290810, :sunset=>1712337454})
    # weather =  WeatherAir::WeatherClient.new
    # assert_equal({:sunrise=>1712290810, :sunset=>1712337454}, weather.owm_sunrise_sunset) 
    # https://github.com/freerange/mocha
    owm_weather_forecast_data = {"Saturday 06.04."=>
    [{:description=>"scattered clouds", :icon=>"03n", :temp=>10, :rain=>0},
     {:description=>"broken clouds", :icon=>"04n", :temp=>9, :rain=>0},
     {:description=>"broken clouds", :icon=>"04d", :temp=>12, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04d", :temp=>19, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04d", :temp=>21, :rain=>0},
     {:description=>"scattered clouds", :icon=>"03d", :temp=>21, :rain=>0},
     {:description=>"scattered clouds", :icon=>"03n", :temp=>15, :rain=>0},
     {:description=>"scattered clouds", :icon=>"03n", :temp=>13, :rain=>0}],
   "Sunday 07.04."=>
    [{:description=>"broken clouds", :icon=>"04n", :temp=>12, :rain=>0},
     {:description=>"broken clouds", :icon=>"04n", :temp=>11, :rain=>0},
     {:description=>"scattered clouds", :icon=>"03d", :temp=>14, :rain=>0},
     {:description=>"clear sky", :icon=>"01d", :temp=>20, :rain=>0},
     {:description=>"clear sky", :icon=>"01d", :temp=>23, :rain=>0},
     {:description=>"clear sky", :icon=>"01d", :temp=>22, :rain=>0},
     {:description=>"clear sky", :icon=>"01n", :temp=>15, :rain=>0},
     {:description=>"broken clouds", :icon=>"04n", :temp=>13, :rain=>0}],
   "Monday 08.04."=>
    [{:description=>"broken clouds", :icon=>"04n", :temp=>12, :rain=>0},
     {:description=>"few clouds", :icon=>"02n", :temp=>11, :rain=>0},
     {:description=>"scattered clouds", :icon=>"03d", :temp=>14, :rain=>0},
     {:description=>"clear sky", :icon=>"01d", :temp=>21, :rain=>0},
     {:description=>"few clouds", :icon=>"02d", :temp=>24, :rain=>0},
     {:description=>"scattered clouds", :icon=>"03d", :temp=>23, :rain=>0},
     {:description=>"scattered clouds", :icon=>"03n", :temp=>16, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04n", :temp=>14, :rain=>0}],
   "Tuesday 09.04."=>
    [{:description=>"overcast clouds", :icon=>"04n", :temp=>13, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04n", :temp=>12, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04d", :temp=>14, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04d", :temp=>20, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04d", :temp=>22, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04d", :temp=>22, :rain=>0},
     {:description=>"broken clouds", :icon=>"04n", :temp=>15, :rain=>0},
     {:description=>"broken clouds", :icon=>"04n", :temp=>13, :rain=>0}],
   "Wednesday 10.04."=>
    [{:description=>"overcast clouds", :icon=>"04n", :temp=>12, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04n", :temp=>11, :rain=>0},
     {:description=>"overcast clouds", :icon=>"04d", :temp=>11, :rain=>0},
     {:description=>"light rain", :icon=>"10d", :temp=>8, :rain=>0.21},
     {:description=>"light rain", :icon=>"10d", :temp=>8, :rain=>0.3}]}
    owm_weather_forecast_data_bs = {"subota 06.04."=>
    [{:description=>"raštrkani oblaci", :icon=>"03n", :temp=>10, :rain=>0},
     {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>9, :rain=>0},
     {:description=>"isprekidani oblaci", :icon=>"04d", :temp=>12, :rain=>0},
     {:description=>"oblačno", :icon=>"04d", :temp=>19, :rain=>0},
     {:description=>"oblačno", :icon=>"04d", :temp=>21, :rain=>0},
     {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>21, :rain=>0},
     {:description=>"raštrkani oblaci", :icon=>"03n", :temp=>15, :rain=>0},
     {:description=>"raštrkani oblaci", :icon=>"03n", :temp=>13, :rain=>0}],
   "nedjelja 07.04."=>
    [{:description=>"isprekidani oblaci", :icon=>"04n", :temp=>12, :rain=>0},
     {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>11, :rain=>0},
     {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>14, :rain=>0},
     {:description=>"vedro", :icon=>"01d", :temp=>20, :rain=>0},
     {:description=>"vedro", :icon=>"01d", :temp=>23, :rain=>0},
     {:description=>"vedro", :icon=>"01d", :temp=>22, :rain=>0},
     {:description=>"vedro", :icon=>"01n", :temp=>15, :rain=>0},
     {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>13, :rain=>0}],
   "ponedjeljak 08.04."=>
    [{:description=>"isprekidani oblaci", :icon=>"04n", :temp=>12, :rain=>0},
     {:description=>"blaga naoblaka", :icon=>"02n", :temp=>11, :rain=>0},
     {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>14, :rain=>0},
     {:description=>"vedro", :icon=>"01d", :temp=>21, :rain=>0},
     {:description=>"blaga naoblaka", :icon=>"02d", :temp=>24, :rain=>0},
     {:description=>"raštrkani oblaci", :icon=>"03d", :temp=>23, :rain=>0},
     {:description=>"raštrkani oblaci", :icon=>"03n", :temp=>16, :rain=>0},
     {:description=>"oblačno", :icon=>"04n", :temp=>14, :rain=>0}],
   "utorak 09.04."=>
    [{:description=>"oblačno", :icon=>"04n", :temp=>13, :rain=>0},
     {:description=>"oblačno", :icon=>"04n", :temp=>12, :rain=>0},
     {:description=>"oblačno", :icon=>"04d", :temp=>14, :rain=>0},
     {:description=>"oblačno", :icon=>"04d", :temp=>20, :rain=>0},
     {:description=>"oblačno", :icon=>"04d", :temp=>22, :rain=>0},
     {:description=>"oblačno", :icon=>"04d", :temp=>22, :rain=>0},
     {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>15, :rain=>0},
     {:description=>"isprekidani oblaci", :icon=>"04n", :temp=>13, :rain=>0}],
   "srijeda 10.04."=>
    [{:description=>"oblačno", :icon=>"04n", :temp=>12, :rain=>0},
     {:description=>"oblačno", :icon=>"04n", :temp=>11, :rain=>0},
     {:description=>"oblačno", :icon=>"04d", :temp=>11, :rain=>0},
     {:description=>"slaba kiša", :icon=>"10d", :temp=>8, :rain=>0.21},
     {:description=>"slaba kiša", :icon=>"10d", :temp=>8, :rain=>0.3}]} 
    WeatherAir::WeatherClient.any_instance.stubs(:owm_weather_forecast).returns(owm_weather_forecast_data)
    WeatherAir::WeatherClient.any_instance.stubs(:owm_weather_forecast).returns(owm_weather_forecast_data_bs)
    # YAML.load(File.read("test/fixtures/duplicate_meteoalarms.yml")).to_json
    # YAML.load(File.read("test/fixtures/yr_weather.yml")).to_json
    WeatherAir::WeatherClient.any_instance.stubs(:yr_weather).returns(yr_weather_data)
    WeatherAir::WeatherClient.any_instance.stubs(:meteoalarms).returns([[], []])

    WeatherAir::AirQualityIndex.any_instance.stubs(:city_pollutants_aqi).returns({:so2=>1, :no2=>1, :o3=>4, :pm10=>2, :pm25=>1, :value=>4, :class=>:poor_eea})
    stations_pollutants_aqi_data = {"vijecnica"=>
    {:aqi=>{:value=>"1", :class=>:good_eea},
     :so2=>{:value=>"1", :class=>:good_eea},
     :no2=>{:value=>"1", :class=>:good_eea},
     :o3=>{:value=>"", :class=>nil},
     :pm10=>{:value=>"1", :class=>:good_eea},
     :pm25=>{:value=>"", :class=>nil},
     :name=>"Vijećnica",
     :latitude=>43.859,
     :longitude=>18.434},
   "bjelave"=>
    {:aqi=>{:value=>"4", :class=>:poor_eea},
     :so2=>{:value=>"1", :class=>:good_eea},
     :no2=>{:value=>"1", :class=>:good_eea},
     :o3=>{:value=>"4", :class=>:poor_eea},
     :pm10=>{:value=>"1", :class=>:good_eea},
     :pm25=>{:value=>"1", :class=>:good_eea},
     :name=>"Bjelave",
     :latitude=>43.867,
     :longitude=>18.42},
   "otoka"=>
    {:aqi=>{:value=>"3", :class=>:moderate_eea},
     :so2=>{:value=>"1", :class=>:good_eea},
     :no2=>{:value=>"1", :class=>:good_eea},
     :o3=>{:value=>"3", :class=>:moderate_eea},
     :pm10=>{:value=>"2", :class=>:fair_eea},
     :pm25=>{:value=>"1", :class=>:good_eea},
     :name=>"Otoka",
     :latitude=>43.848,
     :longitude=>18.363},
   "ilidza"=>
    {:aqi=>{:value=>"1", :class=>:good_eea},
     :so2=>{:value=>"1", :class=>:good_eea},
     :no2=>{:value=>"1", :class=>:good_eea},
     :o3=>{:value=>"", :class=>nil},
     :pm10=>{:value=>"1", :class=>:good_eea},
     :pm25=>{:value=>"1", :class=>:good_eea},
     :name=>"Ilidža",
     :latitude=>43.83,
     :longitude=>18.31},
   "vogosca"=>
    {:aqi=>{:value=>"1", :class=>:good_eea},
     :so2=>{:value=>"1", :class=>:good_eea},
     :no2=>{:value=>"1", :class=>:good_eea},
     :o3=>{:value=>"", :class=>nil},
     :pm10=>{:value=>"1", :class=>:good_eea},
     :pm25=>{:value=>"1", :class=>:good_eea},
     :name=>"Vogošća",
     :latitude=>43.9,
     :longitude=>18.342},
   "hadzici"=>
    {:aqi=>{:value=>"2", :class=>:fair_eea},
     :so2=>{:value=>"1", :class=>:good_eea},
     :no2=>{:value=>"1", :class=>:good_eea},
     :o3=>{:value=>"2", :class=>:fair_eea},
     :pm10=>{:value=>"", :class=>nil},
     :pm25=>{:value=>"", :class=>nil},
     :name=>"Hadžići",
     :latitude=>43.823,
     :longitude=>18.2},
   "ilijas"=>
    {:aqi=>{:value=>"2", :class=>:fair_eea},
     :so2=>{:value=>"", :class=>nil},
     :no2=>{:value=>"1", :class=>:good_eea},
     :o3=>{:value=>"", :class=>nil},
     :pm10=>{:value=>"2", :class=>:fair_eea},
     :pm25=>{:value=>" ", :class=>nil},
     :name=>"Ilijaš",
     :latitude=>43.96,
     :longitude=>18.269},
   "ivan_sedlo"=>
    {:aqi=>{:value=>"4", :class=>:poor_eea},
     :so2=>{:value=>"1", :class=>:good_eea},
     :no2=>{:value=>"", :class=>nil},
     :o3=>{:value=>"4", :class=>:poor_eea},
     :pm10=>{:value=>"", :class=>nil},
     :pm25=>{:value=>"", :class=>nil},
     :name=>"Ivan sedlo",
     :latitude=>43.75,
     :longitude=>18.035}}
    WeatherAir::AirQualityIndex.any_instance.stubs(:stations_pollutants_aqi_data).returns(stations_pollutants_aqi_data)
    ks_aqi_data = {"Vijećnica"=>
    {:name=>"vijecnica",
     :latitude=>43.859,
     :longitude=>18.434,
     "SO2"=>{:date=>'2024-01-29 14:00:00 +0100', :time=>'2024-04-05 14:00:00 +0200', :display=>false, :concentration=>"9.42 μg/m3", :css_class=>"good", :aqi=>"5"},
     "NO2"=>{:date=>'2024-01-29 14:00:00 +0100', :time=>'2024-04-05 14:00:00 +0200', :display=>false, :concentration=>"25.28 μg/m3", :css_class=>"good", :aqi=>"12"},
     "CO"=>{:date=>'2024-01-29 14:00:00 +0100', :time=>'2024-04-05 14:00:00 +0200', :display=>false, :concentration=>"0.33 mg/m3", :css_class=>"good", :aqi=>"3"},
     "O3"=>{},
     "PM10"=>{:date=>'2024-01-29 14:00:00 +0100', :time=>'2024-04-05 14:00:00 +0200', :display=>false, :concentration=>"23.39 μg/m3", :css_class=>"good", :aqi=>"22"},
     "PM2.5"=>{}},
   "Otoka"=>
    {:name=>"otoka",
     :latitude=>43.848,
     :longitude=>18.363,
     "SO2"=>{:date=>'2024-02-26 10:00:00 +0100', :time=>'2024-04-05 10:00:00 +0200', :display=>false, :concentration=>"19.94 μg/m3", :css_class=>"good", :aqi=>"11"},
     "NO2"=>{:date=>'2024-02-26 10:00:00 +0100', :time=>'2024-04-05 10:00:00 +0200', :display=>false, :concentration=>"61.74 μg/m3", :css_class=>"good", :aqi=>"30"},
     "CO"=>{},
     "O3"=>{:date=>'2024-02-26 10:00:00 +0100', :time=>'2024-04-05 10:00:00 +0200', :display=>false, :concentration=>"10.96 μg/m3", :css_class=>"good", :aqi=>"5"},
     "PM10"=>{:date=>'2024-02-26 10:00:00 +0100', :time=>'2024-04-05 10:00:00 +0200', :display=>false, :concentration=>"86.42 μg/m3", :css_class=>"moderate", :aqi=>"67"},
     "PM2.5"=>{}},
   "Ilidža"=>
    {:name=>"ilidza",
     :latitude=>43.83,
     :longitude=>18.31,
     "SO2"=>{:date=>'2023-05-07 02:00:00 +0200', :time=>'2024-04-05 02:00:00 +0200', :display=>false, :concentration=>"6.88 μg/m3", :css_class=>"good", :aqi=>"4"},
     "NO2"=>{:date=>'2023-05-07 02:00:00 +0200', :time=>'2024-04-05 02:00:00 +0200', :display=>false, :concentration=>"9.04 μg/m3", :css_class=>"good", :aqi=>"4"},
     "CO"=>{},
     "O3"=>{},
     "PM10"=>{:date=>'2023-05-07 02:00:00 +0200', :time=>'2024-04-05 02:00:00 +0200', :display=>false, :concentration=>"13.87 μg/m3", :css_class=>"good", :aqi=>"13"},
     "PM2.5"=>{:date=>'2023-05-07 02:00:00 +0200', :time=>'2024-04-05 02:00:00 +0200', :display=>false, :concentration=>"9.67 μg/m3", :css_class=>"good", :aqi=>"40"}},
   "Vogošća"=>
    {:name=>"vogosca",
     :latitude=>43.9,
     :longitude=>18.342,
     "SO2"=>{:date=>'2024-01-29 14:00:00 +0100', :time=>'2024-04-05 14:00:00 +0200', :display=>false, :concentration=>"16.37 μg/m3", :css_class=>"good", :aqi=>"9"},
     "NO2"=>{:date=>'2024-01-29 14:00:00 +0100', :time=>'2024-04-05 14:00:00 +0200', :display=>false, :concentration=>"18.66 μg/m3", :css_class=>"good", :aqi=>"9"},
     "CO"=>{},
     "O3"=>{},
     "PM10"=>{:date=>'2024-01-29 14:00:00 +0100', :time=>'2024-04-05 14:00:00 +0200', :display=>false, :concentration=>"32.54 μg/m3", :css_class=>"good", :aqi=>"30"},
     "PM2.5"=>{:date=>'2024-01-29 14:00:00 +0100', :time=>'2024-04-05 14:00:00 +0200', :display=>false, :concentration=>"20.89 μg/m3", :css_class=>"moderate", :aqi=>"69"}},
   "Ilijaš"=>
    {:name=>"ilijas",
     :latitude=>43.96,
     :longitude=>18.269,
     "SO2"=>{:date=>'2024-04-05 16:00:00 +0200', :time=>'2024-04-05 16:00:00 +0200', :display=>true, :concentration=>"0.00 μg/m3", :css_class=>nil, :aqi=>"-"},
     "NO2"=>{:date=>'2024-04-05 16:00:00 +0200', :time=>'2024-04-05 16:00:00 +0200', :display=>true, :concentration=>"1.00 μg/m3", :css_class=>"good", :aqi=>"0"},
     "CO"=>{},
     "O3"=>{},
     "PM10"=>{:date=>'2024-04-05 16:00:00 +0200', :time=>'2024-04-05 16:00:00 +0200', :display=>true, :concentration=>"14.35 μg/m3", :css_class=>"good", :aqi=>"13"},
     "PM2.5"=>{}}}
    WeatherAir::AirQualityIndex.any_instance.stubs(:aqi_by_ks).returns(ks_aqi_data)
    eko_akcija_aqi_data = [[["Ambasada SAD", "", "14", "", "60", "Umjereno zagađen"],
    ["Vijećnica", "10", "9", "1", "42", "Dobar"],
    ["Otoka", "10", "4", "8", "21", "Dobar"],
    ["Bjelave", "11", "4", "7", "17", "Dobar"],
    ["Ilidža", "6", "3", "3", "13", "Dobar"]],
   60,
   "moderate"]
    WeatherAir::AirQualityIndex.any_instance.stubs(:aqi_by_ekoakcija).returns(eko_akcija_aqi_data)
    WeatherAir.run

  end

  def test_run_error
    WeatherAir::WeatherClient.expects(:new).raises(StandardError)
    Sentry.expects(:capture_exception)
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