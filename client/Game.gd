extends Node

var url = "ws://127.0.0.1:5000"
var ws = null # empty var for WebSocketClient
var myID = null # 
var Clients = {} # empty clients dict
var othClient = preload("res://Player/otherPlayer.tscn") # load the other client scene
onready var chat = $UI/Chat # link to chat
func _ready(): 
	$UI/Menu.show() # show the name and color menu on ready
func _connect():
	ws = WebSocketClient.new() # Init WebSocket
	ws.connect("connection_established", self, "_connection_established") # connect Callbacks
	ws.connect("connection_closed", self, "_connection_closed") # connect Callbacks
	ws.connect("connection_error", self, "_connection_error") # Connect Callbacks
	ws.connect_to_url(url) # Do the connection 

func _connection_established(protocol): # Called on succesful connection to server
	## Just hides the connection related stuff and shows the other controls
	print("Connection established with protocol: ", protocol)
	$UI/Menu.hide() 

func _connection_closed(m): # called on server closed
	## Shows connection related stuff, Hides the other stuff, Prints error to Label
	get_tree().reload_current_scene()
	print(m)

func _connection_error(): # called when client disconnects abruptly
	## Shows connection related stuff, Hides the other stuff, Prints error to Label
	$UI/Menu/Label.text = "Disconnected from server"
	$UI/Menu.show()
	pass

func _process(_delta): # Process is the main loop, delta is time time last frame in ms
	if ws == null:
		## ws has not been initialised
		## do nothing
		return
	else:
		if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
			## if we are connecting or connected poll the server
			ws.poll()
		if ws.get_peer(1).is_connected_to_host():
			## if we are connected check for messages
			if ws.get_peer(1).get_available_packet_count() > 0 :
				## if there are packets waiting get the next one
				var test = ws.get_peer(1).get_packet()
				#print('recieve %s' % test.get_string_from_ascii ())
				## put it through the parser
				parser(parse_json(test.get_string_from_ascii()))
func sendPos(pos): ## sends the player posintion to the server
	if ws == null or myID == null: ## we either never connected or never got an ID
		return # die
	if ws.get_peer(1).is_connected_to_host(): ## we are connected 
		## This is less complex than it looks
		ws.get_peer(1).put_packet(to_json({"command":"pos","id":myID,"val":pos}).to_utf8()) 
	else:
		return
		#print("not connected")
 ## sends chat message
func sendChat(message): ## send a chat message to the server
	if ws == null or myID == null:
		return
	if ws.get_peer(1).is_connected_to_host():
		ws.get_peer(1).put_packet(to_json({"command":"chat","id":myID,"val":{"user":$UI/Menu/LineEdit.text,"message":message}}).to_utf8())
	else:
		return
		#print("not connected")
func parser(packet): # parses JSON received from server
	# check packet is actually JSON
	if typeof(packet) != 18:
		# exit if not
		print("Wrong data type")
		return
	# get ping reply
	if packet.command == "ping": ## The server wants to check we are alive
		if ws == null or myID == null:
			return
		if ws.get_peer(1).is_connected_to_host():
			ws.get_peer(1).put_packet(to_json({"command":"pong","id":myID}).to_utf8())
		else:
			return
	if packet.command == "pong": ## the server replied when we checked it was alive
		# we just get the timestamp we send back, so just sub that from the current time
		var diff = (OS.get_unix_time() - int(packet.val))
		print("Ping took "+str(diff)+" secs")
	# get own ID
	elif packet.command == "getID": # we got our intial ID from the server
		print("GOT ID "+packet.val)
		myID = packet.val 
		Clients[myID] = {}
		var col = $UI/Menu/ColorPicker.getColour()
		$Room/Player.setMod({"r":col.r,"g":col.g,"b":col.b})
		if ws == null or myID == null:
			return
		if ws.get_peer(1).is_connected_to_host():
			ws.get_peer(1).put_packet(to_json({"command":"reg","id":myID,"user":$UI/Menu/LineEdit.text,"col":{"r":col.r,"g":col.g,"b":col.b}}).to_utf8())
		else:
			return 
	# get chat 
	elif packet.command == "chat": 
		$UI/Chat.doChat(packet.val)
	# get the clients list from server (and everything else)
	elif packet.command == "clientPack":
		#print("got ClientPack")
		for key in packet.val:
			#print("packval "+key)
			if !Clients.has(key):
				print("make new "+key)
				Clients[key] = packet.val[key]
				var othIns = othClient.instance()
				othIns.set_name(key)
				$Room/Clients.add_child(othIns)
				if Clients[key].has("col"):
					othIns.setCol(Clients[key]["col"])
				if Clients[key].has("user"):
					othIns.setUser(Clients[key]["user"])
					$UI/Chat.doChat({"user":Clients[key]["user"],"message":"has entered the lobby"})
			else:
				#print("exisiting "+key)
				#print(Clients)
				Clients[key] = packet.val[key]
				if key == myID:
					pass
				else:
					var n = $Room/Clients.get_node(key)
					#print("set other pos")
					var t = Clients[key]["pos"]
					#print(t)
					n.setPos(t)
		var toErase = []
		#print("now clients")
		for client in Clients.duplicate():
			#print("client "+client)
			if !packet.val.has(client):
				print("key not exist "+client)
				toErase.push_back(client)
		if toErase.size() != 0:
			for i in range(toErase.size()):
				#print("before")
				#print(Clients)
				$UI/Chat.doChat({"user":Clients[toErase[i]]["user"],"message":"has left the lobby"})
				Clients.erase(toErase[i])
				#print("after")
				#print(Clients)
				if $Room/Clients.has_node(toErase[i]):
					print("found node to remove")
					$Room/Clients.get_node(toErase[i]).die()
				else:
					print("not find node")

func _on_Button_pressed():
	if $UI/Menu/LineEdit.text == "":
		$UI/Menu/Error.text = "You must enter a name"
		return
	else:
		_connect() 
	pass # Replace with function body.
