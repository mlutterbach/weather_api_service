class WeatherController < ApplicationController
  require 'redis'
  require 'httparty'

  def fetch_weather
    city = params[:city]
    redis = Redis.new
    cache_key = "weather:#{city}"

    if redis.exists?(cache_key)
      render json: JSON.parse(redis.get(cache_key))
    else
      api_key = ENV['VISUAL_CROSSING_API_KEY']
      response = HTTParty.get("https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/#{city}?key=#{api_key}")

      if response.success?
        redis.set(cache_key, response.body, ex: 12 * 60 * 60)
        render json: response.parsed_response
      else
        render json: { error: "Unable to fetch weather data for #{city}" }, status: :bad_request
      end
    end
  end
end
