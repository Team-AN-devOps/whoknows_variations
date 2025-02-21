require 'httparty'

# API endpoint for weather dat
get '/api/weather' do
  content_type :json
  lat = params[:lat]
  lon = params[:lon]

  if lat.nil? || lon.nil?
    status 400
    return { error: "Latitude and longitude parameters are required." }.to_json
  end

  begin
    cache_key = "weather_#{lat}_#{lon}"
    cached_weather = redis.get(cache_key)

    if cached_weather
      @weather = JSON.parse(cached_weather)
    else
      api_key = ENV['OPENWEATHER_API_KEY']
      raise "API key is missing" unless api_key

      url = "https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&units=metric&appid=#{api_key}"
      response = HTTParty.get(url)

      if response.code == 200
        @weather = JSON.parse(response.body)
        redis.set(cache_key, @weather.to_json)
        redis.expire(cache_key, 1800)
      else
        status response.code
        return { error: "Failed to fetch weather data: #{response.message}" }.to_json
      end
    end

    @weather.to_json
  rescue => e
    status 500
    { error: "An error occurred: #{e.message}" }.to_json
  end
end

# API endpoint for search
get '/api/search' do
  content_type :json
  query = params['q']
  language = params['language'] || 'en'

  db = connect_db

  if query.nil? || query.strip.empty?
    { search_results: [] }.to_json
  else
    search_results = db.exec_params(
      "SELECT * FROM pages WHERE language = $1 AND content ILIKE $2",
      [language, "%#{query}%"]
    ).to_a
    { search_results: search_results }.to_json
  end
end
