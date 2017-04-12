%w[lib app].each { |path| $LOAD_PATH.unshift(__dir__, path) }

require 'sinatra'
require 'server'

# use Rack::Static, :urls => ["/folder_a", "/folder_b"], :root => ::File.expand_path("submodule/public")

run Sinatra::Application
