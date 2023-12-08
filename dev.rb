require './src/weather_air'
require 'dotenv/load'

result = WeatherAir.new.run
File.write('index.html', result)
