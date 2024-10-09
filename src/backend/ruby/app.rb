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
