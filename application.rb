require 'sinatra/base'

class Application < Sinatra::Application
  enable :sessions

  def initialize(app=nil)
    super(app)

    # initialize any other instance variables for you
    # application below this comment. One example would be repositories
    # to store things in a database.
  end

  get '/' do
    if session[:user_id]
      user_id = session[:user_id]
      user = DB[:users][:id => user_id]
      user_email = user[:user_email]
    else
      user_email = nil
    end

    erb :index, locals: {user: user_email}

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

    if DB[:users][:user_email => params[:user_email]].nil? || BCrypt::Password.new(DB[:users][:user_email => params[:user_email]][:password_digest]) != params[:user_password]
      erb :login, locals: {login_error: 'Email/password is invalid'}
    else
      session[:user_id] = DB[:users][:user_email => params[:user_email]][:id]
      redirect '/'
    end
  end
end