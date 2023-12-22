require './src/weather_air'
require 'aws-sdk-s3'
require 'aws-sdk-cloudfront'
require 'time'

def lambda_handler(event:, context:)
  (bosnian, english, feed) = WeatherAir.run
  s3_object_bs = Aws::S3::Object.new(ENV['BUCKET'], 'index.html')
  s3_object_bs.put( { body: bosnian, content_type: 'text/html' } )
  s3_object_en = Aws::S3::Object.new(ENV['BUCKET'], 'en/index.html')
  s3_object_en.put( { body: english, content_type: 'text/html' } )
  s3_object_feed = Aws::S3::Object.new(ENV['BUCKET'], 'feed.json')
  s3_object_feed.put( { body: feed, content_type: 'application/json' } )
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
end
