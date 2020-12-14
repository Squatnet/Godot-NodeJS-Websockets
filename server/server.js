// WebSocket // 

// Communicates with Godot Clients
const WebSocket = require('ws');
var wss = new WebSocket.Server({port: 5000});
var CLIENTS = {}; // hold client stuff
function noop() {} 

// 
function heartbeat() {
  this.isAlive = true; 
}
// checks clients are connected
const interval = setInterval(() => {
    //console.log("INTERVAL");
    for (const [key, value] of Object.entries(CLIENTS)) {
		
		if (value.ws.isAlive === false){
		// if the client did not respond last time		
			console.log(value.ws.id," is dead");
			var wsID = value.ws.id;
			//console.log(CLIENTS[value.ws.id]);
			delete CLIENTS[value.ws.id];
			//console.log(CLIENTS[value.ws.id]);
			return value.ws.terminate();
		} else {
			// the client did respond last time so ping them again
			//console.log(value.ws.id," is Alive");
			//console.log(value.ws.isAlive)
			value.ws.isAlive = false;
			//console.log(value.ws.isAlive)
			var toSend = {"command":"ping","val":value.ws.id,}; // make JSON reply
			value.ws.send(JSON.stringify(toSend))
		}
	}
}, 30000);
// creates unique ID
wss.getUniqueID = function () {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    }
    return s4() + s4() + '-' + s4();
};
// Broadcast message to all clients
function sendAll (message) {
	//console.log("SENDALL CALLED, ",message);
	for (const [key, value] of Object.entries(CLIENTS)) {
        value.ws.send(message);
		//console.log("sent to ",key);
    }
}
// create full client list
function packClients(){
	var pack = {}
	for (const [key, value] of Object.entries(CLIENTS)){
		pack[key] = {"pos":value.pos,"user":value.user,"col":value.col};
	}
	return pack;
}

// New client connection
wss.on('connection', function connection(ws, req) {
	ws.id = wss.getUniqueID(); // make id
	ws.isAlive = true; // is just connected
	CLIENTS[ws.id] = {"pos":[0,0],"ws":ws,"col":{}}; // create empty obejct
	console.log("New Client Added ",ws.id); 
	//console.log("CLIENTS - ");
	var reply = {"command":"getID","val":ws.id,}; // make JSON reply
	ws.send(JSON.stringify(reply))
	ws.on('message', function incoming(message) { // message received
		message = message.toString(); // its an array of byte so make it a string
		message = message.replace(/[^A-Za-z 0-9 \.,\?""!@#\$%\^&\*\(\)-_=\+;:<>\/\\\|\}\{\[\]`~]*/g, ''); // strip any non-ascii chars
		if (message.indexOf('{') !== 0){ // make sure the message is valid JSON
			message = message.substring(message.indexOf('{')) // try and make it valid if it isnt.. 
		}
		var obj = JSON.parse(message); // parse the JSON 
		//console.log('received message: ', message); 
		if(obj.command === "ping"){ // Pin request
			console.log('got ping request at: ',obj.val) 
			var reply = {"command":"pong","val":obj.val,}; // make JSON reply
			ws.send(JSON.stringify(reply)); // Turn JSON to String and send
		}
		else if (obj.command === "pong"){
			// client replies to heartBeat
			ws.isAlive = true;
		}
		else if (obj.command === "chat"){
			// chat message
			var reply = {"command":"chat","val":obj.val,};
			sendAll(JSON.stringify(reply));
		}
		else if (obj.command === "pos"){ // Player Position package
			//console.log("got pos from ",obj.id," ",obj.val)
			CLIENTS[obj.id]["pos"] = obj.val;
			var packed = {"command":"clientPack","val":packClients()}
			sendAll(JSON.stringify(packed));
		}
		else if (obj.command === "reg"){
			// New user filled out name and color
			CLIENTS[obj.id]["user"] = obj.user;
			CLIENTS[obj.id]["col"] = obj.col;
		}
	})
});


// Express //
// Serves up the HTML5 Export // 
const HTTP_PORT = 2000 // Port for Express
var express = require('express'); 
var app = express(); 
var serv = require('http').Server(app);
app.get('/',function(req,res) {
	 res.sendFile(__dirname + '/client/index.html'); // serve index.html file
 });
app.use('/',express.static(__dirname + '/client')); // serve files from "client" directory on server root
serv.listen(HTTP_PORT); // express listen for clients
