require './src/weather_air'
require 'dotenv/load'

result = WeatherAir.run
File.write('index.html', result)
