# Use Ruby image
FROM ruby:3.2

# Install necessary dependencies and set up the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock from src/ruby
COPY ../src/backend/ruby /app
RUN apt-get update -qq && apt-get install -y libpq-dev && bundle install

# Copy the rest of the application
COPY src/backend/ruby /app

# Expose Sinatra's default port
EXPOSE 4567

# Start the application
CMD ["bundle", "exec", "ruby", "app.rb"]