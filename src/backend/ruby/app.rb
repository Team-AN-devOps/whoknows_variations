require 'sinatra'
require 'dotenv/load'
require 'redis'
require 'pg'
require 'sinatra/flash'
require 'httparty'
require 'sinatra/contrib'
require 'rack/cache'


# Require other files
require_relative 'db'
require_relative 'sessions'
require_relative 'cache'
require_relative 'api'

# Enable sessions
enable :sessions
set :session_secret, 'da3259994058f90b0b08ab4650096c506825cd0a38fe40666c0f751e9ab21f5f'

# Configure Sinatra for production

configure do
  set :bind, '0.0.0.0'  # Ensure binding to 0.0.0.0 for all environments
  set :port, 4567
end

configure :production do
  # You can add production-specific configurations here if necessary
end

configure :development do
  # Development-specific configurations can go here, if necessary
end

# Main route
get '/' do
  query = params['q']
  language = params['language'] || 'en'
  search_results = search(query, language)
  erb :search, locals: { search_results: search_results, query: query }
end

# About route
get '/about' do
  erb :about, locals: { user: current_user }
end

# Check the Search Results
def search(query, language)
  db = connect_db
  db.exec_params("SELECT * FROM pages WHERE language = $1 AND content ILIKE $2", [language, "%#{query}%"]).to_a
end
