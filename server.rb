require 'em-websocket'
require 'json'

class Client  
  attr_accessor :name
  
  def initialize
    @name = (0...8).map { (65 + rand(26)).chr }.join
  end
end

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
      msg = {msg: "Someone Connected!"}.to_json
      @channel.push msg
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      
      puts "Recieved message: #{msg}"
      @channel.push msg
      # ws.send msg
    }
  end
}
