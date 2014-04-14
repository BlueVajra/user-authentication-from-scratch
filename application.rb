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
    session[:user_id] = DB[:users].insert(:user_email => params[:user_email], :password_digest => params[:user_password])
    redirect '/'
  end
end