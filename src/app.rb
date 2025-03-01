require 'sinatra'
require 'dotenv/load'
require 'redis'
require 'pg'
require 'sinatra/flash'
require 'httparty'
require 'sinatra/contrib'
require 'rack/cache'
require 'prometheus/client'
require 'prometheus/client/formats/text'

# Disable protection globally for the entire app
disable :protection

# Allow localhost and Docker network access
use Rack::Protection::HostAuthorization, :allowed_ips => ['0.0.0.0/0', 'localhost', 'host.docker.internal', 'prometheus']

# Create a Prometheus client registry
prometheus = Prometheus::Client.registry

# Create a counter for HTTP requests with a 'status' label
http_requests = Prometheus::Client::Counter.new(:http_requests_total, docstring: 'Total number of HTTP requests', labels: [:status])

# Register the counter with the registry
prometheus.register(http_requests)

# Expose the metrics at the /metrics endpoint
get '/metrics' do
  # Disable Host Authorization for this route only
  request.env['rack.protection.hostauth'] = nil

  # Increment the counter for each request with the status label
  http_requests.increment(labels: { status: response.status.to_s })

  # Return the metrics in the format Prometheus understands
  content_type 'text/plain'
  Prometheus::Client::Formats::Text.marshal(prometheus)
end

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

get '/weather' do
  erb :weather, locals: { user: current_user }
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
