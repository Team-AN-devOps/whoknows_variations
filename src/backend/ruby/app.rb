require 'sinatra'
require 'sqlite3'
require 'digest'

# Configuration
set :database_path, '/tmp/whoknows.db'
set :secret_key, 'development key'

use Rack::Session::Cookie, secret: settings.secret_key

# Helper function to connect to the database
def connect_db
  db_exists = File.exist?(settings.database_path)
  halt 500, "Database not found" unless db_exists

  db = SQLite3::Database.new(settings.database_path)
  db.results_as_hash = true
  db
end

# Security Functions
def hash_password(password)
  Digest::MD5.hexdigest(password)
end

def verify_password(stored_hash, password)
  stored_hash == hash_password(password)
end

# Request Handlers
before do
  @db = connect_db
  @user = session[:user_id] ? query_db("SELECT * FROM users WHERE id = ?", session[:user_id]).first : nil
end

after do
  @db.close if @db
end

# Page Routes (HTML rendering)

# The search page (renders search.html)
get '/' do
  q = params['q']
  language = params['language'] || 'en'
  search_results = q ? query_db("SELECT * FROM pages WHERE language = ? AND content LIKE ?", language, "%#{q}%") : []
  erb :search, locals: { search_results: search_results, query: q }
end

# The about page (renders about.html)
get '/about' do
  erb :about
end

# The login page (renders login.html)
get '/login' do
  redirect to('/') if @user
  erb :login
end

# The registration page (renders register.html)
get '/register' do
  redirect to('/') if @user
  erb :register
end
