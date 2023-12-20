require './src/weather_air'
require 'dotenv/load'

(bosnian, english) = WeatherAir.run
File.write('index.html', bosnian)
File.write('en/index.html', english)
