# Godot HTML5 > NodeJS Websocket + Express
Example of combining a nodejs server serving HTML5 Godot client via express, using websockets.
This is a prrof of concept showing you can use Godot engine to create functional HTML5 client served by NodeJS server using express to serve files and Websockets to communicate basic info

## Quick Start ## 

do `node server.js` from server folder
go to `http://localhost:2000` in a browser

## Server

The server is a very simple Node server that uses express `npm install express` to serve up files directly from the server and websocket (ws) `npm install ws` for communcation with clients
The server tracks 4 booleans (Opt1,Opt2,Opt3,Opt4) in a variable called pack.
The server parses JSON from clients, expecting the data to be a JSON object in the form of ```{"id":*...*,"val":*...*}```

### Commands

* ping - Responds to ping request, Expects Json `val` to be a unix time stamp as string which it returns to the client
* setPck - Sets the `pack` variable and then sends a packet to all clients. Expects JSON `val` to be an object with `Opt1, Opt2, Opt3, Opt4` as keys
* getPck - Sends the `pack` variable with headers to a client, `val` is not required

## Client

To begin enter the correct ip and hit connect to start the connection. (it's probably correct)
the client should do `getPck` as soon as it connects
once connected you can hit ping to run the ping command on the server or hit any number of checkboxes and hit packet to do `setPck` on the server
client receiving `pck` message from server will update colored rectangles. 
If you open multiple tabs in browser you'll see all clinets get update. 


