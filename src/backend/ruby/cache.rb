require 'redis'

def redis
  @redis ||= Redis.new
end

use Rack::Cache,
    verbose: true,
    metastore: 'redis://localhost:6379/0/metastore',
    entitystore: 'redis://localhost:6379/0/entitystore'
