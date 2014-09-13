require 'em-websocket'
require 'json'

EM.run {
  @channel = EM::Channel.new
  
  EM::WebSocket.run(:host => "127.0.0.1", :port => 1234) do |ws|
    ws.onopen { |handshake|
      sid = @channel.subscribe do |msg|
        ws.send msg
      end
      puts "client #{sid}: WebSocket connection open"
      
      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      msg = {
        sender: "Server",
        msg: "Someone Connected!",
        color: "rgb(50,50,50)"
      }.to_json
      @channel.push msg
    }

    ws.onclose {
      @channel.push({
        sender: "Server",
        msg: "Someone disconnected",
        color: "rgb(150,50,50)"
      }.to_json)

      puts "Connection closed"
    }

    ws.onmessage { |msg|
      begin
        puts JSON.parse(msg)
      rescue
        puts msg
      end
      @channel.push msg
    }
  end
}
