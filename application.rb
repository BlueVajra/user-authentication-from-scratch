require 'sinatra/base'

class Application < Sinatra::Application
  enable :sessions

  def initialize(app=nil)
    super(app)
  end

  def invalid_password?(user_password, form_password)
    BCrypt::Password.new(user_password) != form_password
  end

  def registration_validation(user_email, user_password, confirm_password)
    return "User email already taken" if DB[:users][:user_email => user_email]
    return "Password can't be blank" if user_password.strip == ""
    return "Password must be longer than 2 characters" if user_password.length < 3
    return "Passwords do not match" if user_password != confirm_password
  end

  def user_by_id(user_id)
    #user_id = session[:user_id]
    DB[:users][:id => user_id]
  end

  def user_by_email(email)
    DB[:users][:user_email => email]
  end

  get '/' do
    #user_id = session[:user_id]
    user = user_by_id(session[:user_id])
    erb :index, locals: {user: user}
  end

  get '/register' do
    erb :register
  end

  post '/register' do
    error_message = registration_validation(params[:user_email],params[:user_password], params[:confirm_password])
    if error_message
      erb :register, locals: {registration_error: error_message, email: params[:user_email]}
    else
      hashed_pass = BCrypt::Password.create(params[:user_password])
      session[:user_id] = DB[:users].insert(:user_email => params[:user_email], :password_digest => hashed_pass)
      redirect '/'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = user_by_email(params[:user_email])
    if user.nil? || invalid_password?(user[:password_digest], params[:user_password])
      erb :login, locals: {login_error: 'Email/password is invalid'}
    else
      session[:user_id] = user[:id]
      redirect '/'
    end
  end

  get '/users' do
    redirect '/' if session[:user_id].nil?
    user = user_by_id(session[:user_id])
    admin = user[:administrator]
    redirect '/' unless admin

    user_email = user[:user_email]
    erb :users, locals: {users: DB[:users].all, user: user, user_email: user_email}

  end

  get '/user/:id' do
    redirect '/' if session[:user_id].nil?
    user = user_by_id(session[:user_id])
    admin = user[:administrator]
    redirect '/' unless admin

    erb :user, locals: {user: user_by_id(session[:user_id]), user_to_edit: user_by_id(params[:id])}
  end

  put '/user/:id' do
    checked = params[:admin] == 'on' ? true : false
    if checked != user_by_id(params[:id])[:administrator]
      DB[:users].where(id: params[:id]).update(administrator: checked)
    end
    redirect "/users"
  end

  delete '/user/:id' do
    DB[:users].where(id: params[:id]).delete
    redirect "/users"
  end
end