require 'sinatra-websocket'
require 'json'
require 'em-websocket'

set :views, 'app/views'
set :sockets, []

configure do
  file = File.new("log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

get '/ws' do
  pass unless request.websocket?
  @channel = EM::Channel.new

  # logger.info env.keys
  # logger.info env.to_json
  # logger.info request
  env['async.orig_callback'] = env['rack.hijack'] if env['rack.hijack']

  request.websocket do |ws|

    ws.onopen do |handshake|
      sid = @channel.subscribe { |msg| ws.send msg }
      puts "client #{sid}: WebSocket connection open"
      @channel.push({
        sender: "Server",
        msg: "Someone Connected!",
        color: {red: 50, blue: 50, green: 50},
        time: Time.now.strftime('%r')
      }.to_json)
    end

    ws.onclose do |x|
      @channel.push({
        sender: "Server",
        msg: "Someone disconnected",
        color: {red: 150, green: 50, blue: 50},
        time: Time.now.strftime('%r')
      }.to_json)
      puts "Connection closed"
    end

    ws.onmessage do |msg|
      msg = JSON.parse(msg)
      msg[:time] = Time.now.strftime('%r')
      puts msg
      msg['msg'] = msg['msg'].to_s
      @channel.push(msg.to_json)
    end

  end
end

get // do
  redirect '/index.html'
end
