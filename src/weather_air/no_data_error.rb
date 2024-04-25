module WeatherAir
  class NoDataError < StandardError; end
  
  class CustomErrors < Faraday::Middleware
    def on_complete(env)
      raise RuntimeError.new(env[:response_body]) if env[:status].to_i != 200
    end
  end
end