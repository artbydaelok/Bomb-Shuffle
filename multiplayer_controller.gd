extends Control

@export var Address = "174.138.88.177"
@export var port = 8910

@export var max_player_count: int = 2

@onready var lobby_players = $LobbyPlayers

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	if "--server" in OS.get_cmdline_args():
		host_game()

@rpc("any_peer", "call_local")
func start_game():
	# IMPORTANT: this part is NOT CHANGING scenes, but loading one.
	# This instantiates the level for all clients and adds it
	var scene = load("res://level_test.tscn").instantiate()
	get_tree().root.add_child(scene)
	# This hides the multiplayer connect menu.
	self.hide()

# "any_peer" means that it will call on all peers connected to the network, including the clients and server.
# "call_local" means that it calls on this .
@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}
	if multiplayer.is_server():
		for player in GameManager.players:
			send_player_information.rpc(GameManager.players[player].name, player)
			
func _on_host_button_button_down():
	host_game()
	send_player_information(%LineEdit.text, multiplayer.get_unique_id())
	
func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_player_count)
	
	# Checks for errors
	if error != OK:
		print("Cannot host: " + error)
		return
	
	# This sets the compression mode for the packets. 
	# COMPRESS_RANGE_CODER seems to be a good compression mode.
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")
	
func _on_join_button_button_down():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	
	# This sets the compression mode for the packets. 
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_game_button_down():
	# This calls the function on 
	start_game.rpc()
	pass # Replace with function body.

func peer_connected(id):
	print("Player " + str(id) + " connected")

func peer_disconnected(id):
	print("Player " + str(id) + " disconnected")
	
func connected_to_server():
	print("Succesfully connected to server.")
	send_player_information.rpc_id(1, %LineEdit.text, multiplayer.get_unique_id())
	
func connection_failed():
	print("Failed to connect.")

@rpc("any_peer", "call_local")
func update_lobby():
	pass
