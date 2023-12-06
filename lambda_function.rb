require './src/weather_air'

def lambda_handler(event:, context:)
  WeatherAir.new.run
end