require 'sinatra/base'

class Application < Sinatra::Application
  enable :sessions

  def initialize(app=nil)
    super(app)
  end

  def invalid_password?(user_password, form_password)
    BCrypt::Password.new(user_password) != form_password
  end

  get '/' do
    user_id = session[:user_id]
    user = DB[:users][:id => user_id]
    erb :index, locals: {user: user}
  end

  get '/register' do
    erb :register
  end

  post '/register' do
    hashed_pass = BCrypt::Password.create(params[:user_password])
    session[:user_id] = DB[:users].insert(:user_email => params[:user_email], :password_digest => hashed_pass)
    redirect '/'
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = DB[:users][:user_email => params[:user_email]]
    if user.nil? || invalid_password?(user[:password_digest], params[:user_password])
      erb :login, locals: {login_error: 'Email/password is invalid'}
    else
      session[:user_id] = user[:id]
      redirect '/'
    end
  end

  get '/users' do
      redirect '/' if session[:user_id].nil?

      user_id = session[:user_id]
      user = DB[:users][:id => user_id]
      admin = user[:administrator]

      redirect '/' unless admin
      user_email = user[:user_email]
      erb :users, locals: {users: DB[:users].all, user_email: user_email}

  end
end