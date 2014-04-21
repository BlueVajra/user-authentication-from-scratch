$LOAD_PATH.unshift('./')

require 'sequel'
require 'application'
require 'dotenv'
require 'bcrypt'
require 'omniauth'
require 'omniauth-github'

Dotenv.load

environment = ENV["RACK_ENV"] || "development"

connection_string = ENV["DATABASE_URL"] || ENV["DATABASE_URL_#{environment.upcase}"]

DB = Sequel.connect(connection_string)

