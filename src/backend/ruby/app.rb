require 'sinatra'
require 'digest'
require 'sinatra/flash'
require 'dotenv/load'  
require 'redis'
require 'redis-rack-cache'
require 'httparty'
require 'pg' # PostgreSQL library
require 'sinatra/contrib'



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

set :server, 'puma'

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
#set :database_path, '../whoknows.db'


# Connect to the database
# Connect to the PostgreSQL database
def connect_db
  @db ||= PG.connect(ENV['DATABASE_URL'])
end


# Load environment variables
Dotenv.load('.env')


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

get '/db_test' do
  begin
    db = connect_db
    result = db.exec("SELECT version();") # Check PostgreSQL version
    "Connected to PostgreSQL: #{result[0]['version']}"
  rescue PG::Error => e
    "Database connection failed: #{e.message}"
  end
end

# Page routes
# Home route (search page)
# Route for search page
get '/' do
  query = params['q'] # Search query from the form input
  language = params['language'] || 'en' # Default to English if no language specified

  search_results = []
  @error = nil

  if query && !query.strip.empty?
    begin
      db = connect_db
      search_results = db.exec_params(
        "SELECT * FROM pages WHERE language = $1 AND content ILIKE $2",
        [language, "%#{query}%"]
      ).to_a
    rescue PG::Error => e
      @error = "Database error: #{e.message}"
    end
  end

  erb :search, locals: { search_results: search_results, query: query }
end

#Check the Search Results
begin
  db = connect_db
  search_results = db.exec_params(
    "SELECT * FROM pages WHERE language = $1 AND content ILIKE $2",
    [language, "%#{query}%"]
  ).to_a
  puts "Search results: #{search_results}"  # Debug log
rescue PG::Error => e
  @error = "Database error: #{e.message}"
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

get '/db_name' do
  begin
    db = connect_db
    result = db.exec("SELECT current_database();") # Query to get the current database name
    "Connected to database: #{result[0]['current_database']}"
  rescue PG::Error => e
    "Database connection failed: #{e.message}"
  end
end


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