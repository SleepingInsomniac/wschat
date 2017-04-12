%w[lib app].each { |path| $LOAD_PATH.unshift(__dir__, path) }

require 'sinatra'
require 'server'

run Sinatra::Application
