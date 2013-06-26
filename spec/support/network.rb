def new_network(url = "http://localhost:3000", player_id = nil)
  network = Libgss::Network.new(url)
  network.player_id = player_id
  network.consumer_secret = AppGarden.config["consumer_secret"]
  network
end
