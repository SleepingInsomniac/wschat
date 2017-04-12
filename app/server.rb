set :views, 'app/views'
set :sockets, []

get '/ws' do
  pass unless request.websocket?
  @channel = EM::Channel.new
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

get '/' do
  erb :'index.html'
end

get // do
  redirect '/'
end
