require 'sinatra'
require 'sqlite3'
require 'digest'
require 'sinatra/flash'
require 'dotenv/load'  
require 'redis'
require 'redis-rack-cache'
require 'httparty'





use Rack::Cache,
    verbose: true,
    metastore:   'redis://localhost:6379/0/metastore',
    entitystore: 'redis://localhost:6379/0/entitystore'

# Helper method for Redis
def redis
  @redis ||= Redis.new
end

# Enable sessions
enable :sessions

# Set the secret key for session management
set :session_secret, 'da3259994058f90b0b08ab4650096c506825cd0a38fe40666c0f751e9ab21f5f'  # Replace with a strong, random string


configure :development do
  set :bind, '0.0.0.0'  # Add this line to bind the app to all IP addresses
  set :port, 4568
end

configure :production do
  set :bind, '0.0.0.0'  # Add this line to bind the app to all IP addresses
  set :port, 4567
end

# Set the database path to the existing database
#set :database_path, '/tmp/whoknows.db'
set :database_path, '../whoknows.db'

# Connect to the database
def connect_db
  db = SQLite3::Database.new(settings.database_path)
  db.results_as_hash = true
  db
end

# Load environment variables
Dotenv.load('.env')

# Check if the database exists
def check_db_exists
  unless File.exist?(settings.database_path)
    puts "Database not found"
    exit(1)
  end
end

# Call the check before you connect
check_db_exists

# Password hashing function
def hash_password(password)
  Digest::SHA256.hexdigest(password)
end

# Password verification function
def verify_password(stored_password, input_password)
  stored_password == hash_password(input_password)
end

# Helper method to fetch the current user
helpers do
  def current_user
    return nil unless session[:user_id]
    
    db = connect_db
    db.execute("SELECT * FROM users WHERE id = ?", session[:user_id]).first
  end
end

# Page routes
# Home route (search page)
get '/' do
  q = params[:q]
  language = params[:language] || "en"
  db = connect_db

  puts "Searching for: #{q} in language: #{language}"

  search_results = []
  message = nil

  if q.nil? || q.empty?
    message = "Please enter a search query."
  else
    begin
      search_results = db.execute(
        "SELECT * FROM pages WHERE language = ? AND content LIKE ?",
        language,
        "%#{q}%"
      )
    rescue SQLite3::Exception => e
      puts "SQLite error: #{e.message}"
    end

    if search_results.empty?
      message = "Ingen resultater fundet for '#{q}'"
    end
  end

  erb :search, locals: { search_results: search_results, query: q, message: message, user: current_user }
end

get '/weather' do
  erb :weather, locals: { user: current_user }
end


# About route
get '/about' do
  erb :about, locals: { user: current_user }
end

# login route
get '/login' do
  if session[:user_id]
    redirect '/'
  else
    erb :login, locals: { user: current_user }
  end
end

# register route
get '/register' do
  if session[:user_id]
    redirect '/'
  else
    erb :register, locals: { user: current_user }
  end
end

def redis
  @redis ||= Redis.new
end

# API endpoint for search
get '/api/search' do
  content_type :json  # Set the response content type to JSON
  q = params[:q]
  language = params[:language] || "en"

  db = connect_db

  if q.nil? || q.empty?
    search_results = []
  else
    # Use parameterized queries to prevent SQL injection
    search_results = db.execute("SELECT * FROM pages WHERE language = ? AND content LIKE ?", language, "%#{q}%")
  end

  { search_results: search_results }.to_json  # Convert the results to JSON
end

# API login route
post '/api/login' do
  content_type :json  # Set the response content type to JSON
  username = params[:username]
  password = params[:password]

  db = connect_db
  user = db.execute("SELECT * FROM users WHERE username = ?", username).first
  
  if user.nil?
    { error: 'Invalid username' }.to_json
  elsif !verify_password(user['password'], password)
    { error: 'Invalid password' }.to_json
  else
    session[:user_id] = user['id']
    { message: 'You were logged in' }.to_json
  end
end

# API register route
post '/api/register' do
  content_type :json  # Set the response content type to JSON
  username = params[:username]
  email = params[:email]
  password = params[:password]
  password2 = params[:password2]

  db = connect_db
  error = nil

  # Basic validation
  if username.empty?
    error = 'You have to enter a username'
  elsif email.empty? || !email.include?('@')
    error = 'You have to enter a valid email address'
  elsif password.empty?
    error = 'You have to enter a password'
  elsif password != password2
    error = 'The two passwords do not match'
  elsif db.execute("SELECT * FROM users WHERE username = ?", username).any?
    error = 'The username is already taken'
  end

  if error
    { error: error }.to_json
  else
    db.execute("INSERT INTO users (username, email, password) VALUES (?, ?, ?)", username, email, hash_password(password))
    { message: 'You were successfully registered and can log in now' }.to_json
  end
end

# API logout route
get '/api/logout' do
  session[:user_id] = nil
  { message: 'You were logged out' }.to_json
end


get 'api/weather' do
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
        redis.expire(cache_key, 1800) # Cache for 30 minutes
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