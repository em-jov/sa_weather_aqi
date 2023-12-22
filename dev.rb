require './src/weather_air'
require 'dotenv/load'

(bosnian, english, feed) = WeatherAir.run
File.write('index.html', bosnian)
File.write('en/index.html', english)
File.write('feed.json', feed)
