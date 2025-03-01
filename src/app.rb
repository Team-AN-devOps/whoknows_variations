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
require