require 'em-websocket'
require 'json'

EM.run {
  @channel = EM::Channel.new
  
  EM::WebSocket.run(:host => "127.0.0.1", :port => 3001) do |ws|
    ws.onopen { |handshake|
      sid = @channel.subscribe do |msg|
        ws.send msg
      end
      puts "client #{sid}: WebSocket connection open"
      
      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      @channel.push({
        sender: "Server",
        msg: "Someone Connected!",
        color: {red: 50, blue: 50, green: 50},
        time: Time.now.strftime('%r')
      }.to_json)
    }

    ws.onclose { |x|
      puts x
      @channel.push({
        sender: "Server",
        msg: "Someone disconnected",
        color: {red: 150, green: 50, blue: 50},
        time: Time.now.strftime('%r')
      }.to_json)

      puts "Connection closed"
    }

    ws.onmessage { |msg|
      msg = JSON.parse(msg)
      msg[:time] = Time.now.strftime('%r')
      puts msg
      msg['msg'] = msg['msg'].to_s#.gsub(/\</, "&lt;").gsub(/\>/, "&gt;")
      @channel.push(msg.to_json)
    }
  end
}
