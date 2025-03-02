require 'net/http'
require 'json'
require 'uri'
require 'timeout'

BASE_URL = 'http://localhost:4567' # Change if running inside Docker with a different hostname

# Wait for the Sinatra service to be available
def wait_for_service(url, timeout = 30)
  uri = URI(url)
  start_time = Time.now

  loop do
    begin
      response = Net::HTTP.get_response(uri)
      return if response.is_a?(Net::HTTPSuccess) # Stop if service is up
    rescue StandardError
      sleep 2 # Wait and retry
    end

    if Time.now - start_time > timeout
      puts "❌ Timeout: Service not available at #{url}"
      exit(1)
    end
  end
end

# Test /api/weather with no location parameters (should fail)
def test_weather_no_location
  puts "Testing /api/weather without location..."

  uri = URI("#{BASE_URL}/api/weather")
  response = Net::HTTP.get_response(uri)

  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"

  if response.code == "400"
    puts "✅ Location Access Denial Test Passed: API correctly rejected request without location"
  else
    puts "❌ Test failed: Expected 400 for denied location access, got #{response.code}"
  end
end

# Test /api/weather with invalid coordinates
def test_invalid_location
  puts "Testing /api/weather with invalid location..."

  uri = URI("#{BASE_URL}/api/weather?lat=999&lon=999")
  response = Net::HTTP.get_response(uri)

  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"

  if response.code != "200"
    puts "✅ Invalid Location Test Passed: API correctly rejected invalid coordinates"
  else
    puts "❌ Test failed: Expected non-200 response for invalid coordinates, but got 200"
  end
end

# Test /api/weather with valid coordinates
def test_weather_valid
  puts "Testing /api/weather with valid coordinates..."

  uri = URI("#{BASE_URL}/api/weather?lat=55.6761&lon=12.5683") # Copenhagen
  response = Net::HTTP.get_response(uri)

  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"

  if response.code == "200"
    puts "✅ Weather API test passed"
  else
    puts "❌ Test failed: Expected 200, got #{response.code}"
  end
end

# Test /api/search with a valid query
def test_search_valid
  puts "Testing /api/search with a query..."

  uri = URI("#{BASE_URL}/api/search?q=Ruby&language=en")
  response = Net::HTTP.get_response(uri)

  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"

  if response.code == "200"
    puts "✅ Search API test passed"
  else
    puts "❌ Test failed: Expected 200, got #{response.code}"
  end
end

# Test /api/search with no query (should return empty results)
def test_search_no_query
  puts "Testing /api/search with no query..."

  uri = URI("#{BASE_URL}/api/search")
  response = Net::HTTP.get_response(uri)

  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"

  if response.code == "200"
    puts "✅ Search API empty query test passed"
  else
    puts "❌ Test failed: Expected 200, got #{response.code}"
  end
end

# Wait for the Sinatra service before running tests
puts "⏳ Waiting for Sinatra service..."
wait_for_service("#{BASE_URL}/api/search")

# Run all tests
test_weather_no_location
test_invalid_location
test_weather_valid
test_search_valid
test_search_no_query
