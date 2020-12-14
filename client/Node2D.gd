extends Node2D

var ws = null # empty var for WebSocketClient

func _connect(): 
	ws = WebSocketClient.new() # Init WebSocket
	ws.connect("connection_established", self, "_connection_established") # connect Callbacks
	ws.connect("connection_closed", self, "_connection_closed") # connect Callbacks
	ws.connect("connection_error", self, "_connection_error") # Connect Callbacks
	var url = $LineEdit.text # get server URL from LineEdit
	print("Connecting to " + url)
	ws.connect_to_url(url) # Do the connection 

func _connection_established(protocol): # Called on succesful connection to server
	## Just hides the connection related stuff and shows the other controls
	$LineEdit.hide() 
	$btn_connect.hide()
	$btn_packet.show()
	$btn_ping.show()
	$HBoxContainer.show()
	$HBoxContainer2.show()
	var dic = {"id":"getPck","val":""} # create a Dictionary (JSON basically)
	if ws.get_peer(1).is_connected_to_host(): # Make sure we are connected
		ws.get_peer(1).put_var(to_json(dic)) 
	print("Connection established with protocol: ", protocol)
	if ws.get_peer(1).is_connected_to_host():
		ws.get_peer(1).put_var(to_json({"id":"getID"})) 

func _connection_closed(m): # called on server closed
	## Shows connection related stuff, Hides the other stuff, Prints error to Label
	$LineEdit.show() 
	$btn_connect.show()
	$btn_packet.hide()
	$btn_ping.hide()
	$HBoxContainer.hide()
	$HBoxContainer2.hide()
	$Label.text = "Connection closed"
	print(m)

func _connection_error(): # called when client disconnects abruptly
	## Shows connection related stuff, Hides the other stuff, Prints error to Label
	$LineEdit.show()
	$btn_connect.show()
	$btn_packet.hide()
	$btn_ping.hide()
	$HBoxContainer.hide()
	$HBoxContainer2.hide()
	$Label.text = "Connection error"

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
				print('recieve %s' % test.get_string_from_ascii ())
				## put it through the parser
				parser(parse_json(test.get_string_from_ascii()))
				
func parser(packet): # parses JSON received from server
	# check packet is actually JSON
	if typeof(packet) != 18:
		# exit if not
		print("Wrong data type")
		return
	# get ping reply
	if packet.id == "pong":
		# we just get the timestamp we send back, so just sub that from the current time
		var diff = (OS.get_unix_time() - int(packet.val))
		$Label.text = "Ping took "+str(diff)+" secs"
	# get packet reply
	if packet.id == "pck":
		# iterate through the keys
		for key in packet.val:
			# set the colourRect colors
			if packet.val[key] == true:
				print("Set Col to green")
				$HBoxContainer2.get_node(key).color = Color(0,1,0,1)
			else:
				$HBoxContainer2.get_node(key).color = Color(1,0,0,1)

func _on_btn_ping_pressed(): ## Ping button pressed
	var str_time = str(OS.get_unix_time()) # get the current time
	print("send time : " + str_time) 
	var dic = {"id":"ping","val":""} # create a Dictionary (JSON basically)
	if ws.get_peer(1).is_connected_to_host(): # Make sure we are connected
		dic["val"] = str_time # add the time to the dictionary
		ws.get_peer(1).put_var(to_json(dic)) # convert the dictionary to JSON and send it.

func _on_btn_connect_pressed(): ## connect button pressed
	_connect() 

func _on_btn_packet_pressed(): ## packet button pressed
	var pack = {} ## empty dictionary
	for i in $HBoxContainer.get_children(): # get all child nodes on HBoxContainer
		pack[i.get_name()] = i.pressed # add key to pack with node name as key and CheckBox.pressed as value
	var packed = {"id":"setPck","val":str(to_json(pack))} ## adding Headers 
	if ws.get_peer(1).is_connected_to_host(): ## check connected to server
		ws.get_peer(1).put_var(str(to_json(packed))) ## Convert the packed dictionary to JSON and send it
	
