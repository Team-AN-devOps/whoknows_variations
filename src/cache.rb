require 'redis'

def redis
  @redis ||= Redis.new(url: "redis://redis:6379")  # Connect to Redis container by service name
end

use Rack::Cache,
    verbose: true,
    metastore: 'redis://redis:6379/0/metastore',   # Use 'redis' as hostname
    entitystore: 'redis://redis:6379/0/entitystore' # Use 'redis' as hostname
