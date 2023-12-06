# frozen_script_literal: true
require 'erb'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'time'
require 'aws-sdk-s3'
require 'aws-sdk-cloudfront'
Dir['./src/modules/*.rb'].each { |file| require file }

class WeatherAir
  include AqiGuide
  include Weather

  def run
    current_weather = current_weather_data
    latest_aqi_values = latest_pollutant_values_by_monitoring_stations
    pollutants = current_air_pollution_for_city(latest_aqi_values)

    weather_forecast = forecast

    template = ERB.new(File.read('template.html.erb'))
    result = template.result(binding) 
    if ENV['DEVELOPMENT']   
      File.write('index.html', result)
    else 
      s3_object = Aws::S3::Object.new(ENV['BUCKET'], 'index.html')
      s3_object.put( { body: result, content_type: 'text/html' } )
      cloudfront_client = Aws::CloudFront::Client.new
      cloudfront_client.create_invalidation({
        distribution_id: ENV['CLOUDFRONT_DISTRIBUTION'],
        invalidation_batch: { 
          paths: { 
            quantity: 1, 
            items: ["/"],
          },
          caller_reference: Time.now.to_s
        }
      } )
    end
  end

  def last_update 
    Time.now.getlocal('+01:00').to_s
  end

end
