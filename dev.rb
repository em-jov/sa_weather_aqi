require './src/weather_air'
require 'dotenv/load'
require 'logger'

#$logger = Logger.new

(bosnian, english, feed, sa_aqi, ms_aqi) = WeatherAir.run
File.write('index.html', bosnian)
File.write('en/index.html', english)
File.write('json/feed.json', feed)
File.write('json/sa_aqi.json', feed)
File.write('json/ms_aqi.json', feed)
