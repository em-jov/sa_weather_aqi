require './src/weather_air'
require 'aws-sdk-s3'
require 'aws-sdk-cloudfront'
require 'time'

def lambda_handler(event:, context:)
  result = WeatherAir.new.run
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