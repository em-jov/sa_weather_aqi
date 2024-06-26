require './src/weather_air'
require 'aws-sdk-s3'
require 'aws-sdk-cloudfront'
require 'time'
require 'sentry-ruby'

def lambda_handler(event:, context:)
  (bosnian, english, feed, sa_aqi, ms_aqi) = WeatherAir.run

  s3_object_bs = Aws::S3::Object.new(ENV['BUCKET'], 'index.html')
  s3_object_bs.put( { body: bosnian, content_type: 'text/html' } )

  s3_object_en = Aws::S3::Object.new(ENV['BUCKET'], 'en/index.html')
  s3_object_en.put( { body: english, content_type: 'text/html' } )

  s3_object_feed = Aws::S3::Object.new(ENV['BUCKET'], 'json/feed.json')
  s3_object_feed.put( { body: feed, content_type: 'application/json' } )

  s3_object_sa_aqi = Aws::S3::Object.new(ENV['BUCKET'], 'json/sa_aqi.json')
  s3_object_sa_aqi.put( { body: sa_aqi, content_type: 'application/json' } )

  s3_object_ms_aqi = Aws::S3::Object.new(ENV['BUCKET'], 'json/ms_aqi.json')
  s3_object_ms_aqi.put( { body: ms_aqi, content_type: 'application/json' } )

  cloudfront_client = Aws::CloudFront::Client.new
  cloudfront_client.create_invalidation({
    distribution_id: ENV['CLOUDFRONT_DISTRIBUTION'],
    invalidation_batch: { 
      paths: { 
        quantity: 1, 
        items: ["/*"],
      },
      caller_reference: Time.now.to_s
    }
  } )

rescue StandardError => e 
  Sentry.capture_exception(e)  
end
