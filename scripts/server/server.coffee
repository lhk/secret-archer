express = require("express")
app = express();

console.log("express created")

app.use(express.static(__dirname+"../../../"))
console.log("static server runs")

app.set("views", __dirname+"../../../views/")

app.set("view engine", "jade")
console.log("view engine set up")

app.get "/", (req, res)->
	res.render("index") 
	console.log("rendering index")

port = process.env.PORT or 5560
server= app.listen(port)
console.log("server listens to port "+ port)



io=require("socket.io").listen(server)
io.sockets.on "connection", (socket)->
    ids=0
    console.log "connection"
    socket.emit "NEWS", {news:"someone has joined us"}
    
    socket.on "RPCSPAWNREQUEST", (data)->
        socket.emit "RPCSPAWN", {x:data.x, y:data.y, tag:data.tag, id:ids++}
        console.log {x:data.x, y:data.y, tag:data.tag, id:ids}
    
    socket.on "disconnect", ()->
        io.sockets.emit "NEWS", {news:"someone has left us"}
        