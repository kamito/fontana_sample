def new_network(player_id = nil, url = "http://localhost:3000")
  network = Libgss::Network.new(url)
  network.player_id = player_id
  network.consumer_secret = AppGarden.config["consumer_secret"]
  network
end
