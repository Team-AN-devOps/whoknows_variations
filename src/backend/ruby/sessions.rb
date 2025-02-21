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
  
  # API login route
  post '/api/login' do
    content_type :json
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
    content_type :json
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
  