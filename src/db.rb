require 'pg'

def connect_db
  @db ||= PG.connect(
    host: 'postgres',          # The name of the database container in Docker (from docker-compose)
    dbname: 'postgres', # The name of your database
    user: 'postgres',    # The username for the database
    password: 'postgres', # The password for the user
    port: 5432           # Port for PostgreSQL, default is 5432
  )
end


# Debugging the connection
begin
  conn = connect_db
  puts "Database connected successfully!"
rescue PG::Error => e
  puts "Connection failed: #{e.message}"
ensure
  conn.close if conn
end
