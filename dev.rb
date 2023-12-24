require './src/weather_air'
require 'dotenv/load'

(bosnian, english, feed, sa_aqi, ms_aqi) = WeatherAir.run
File.write('index.html', bosnian)
File.write('en/index.html', english)
File.write('feed.json', feed)
File.write('sa_aqi.json', feed)
File.write('ms_aqi.json', feed)
