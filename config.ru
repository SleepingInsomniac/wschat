%w[lib app].each { |path| $LOAD_PATH.unshift(__dir__, path) }

require 'sinatra'
require 'sinatra-websocket'
require 'json'
require 'server'
require 'thin'

set :server, 'thin'

run Sinatra::Application
