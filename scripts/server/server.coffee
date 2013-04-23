# STEP 1: set up the html server

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

class Vector2
    constructor:(x,y)->
        @x=x
        @y=y

    length:()->
        return length=Math.sqrt(Math.pow(@x,2)+Math.pow(@y,2))

    add:(v)->
        @x+=v.x
        @y+=v.y
        return this

    sub:(v)->
        @x-=v.x
        @y-=v.y
        return this

    mul:(scalar)->
        @x*=scalar
        @y*=scalar
        return this

    div:(scalar)->
        @x/=scalar
        @y/=scalar
        return this

    #the functional versions don't modify the original
    funcMul:(scalar)->
        v=new Vector2(@x,@y)
        v.mul(scalar)
        return v

    funcDiv:(scalar)->
        v=new Vector2(@x,@y)
        v.div(scalar)
        return v

    normalize:()->
        @x/=@length()
        @y/=@length()
        return this

    funcNormalize:()->
        v=new Vector2(@x,@y)
        v.div(v.length)
        return v


class Game
    gameObjects:[]
    players:[]
    clients:0
    ids:0
    constructor: ->
        #@gameObjects.push new Factory(0,1,1,0,0, this)
        prev=Date.now()
        now=Date.now()
        setInterval ()=>
                now=Date.now()
                deltaTime=now-prev
                prev=now
                @gameObjects.forEach((obj)->obj.update(deltaTime))
            , 20

    addPlayer:(socket)=>
        console.log "player connected"
        @players[@clients]= socket
        socket.emit "CONNECTED", {clientId: @clients}
        @clients++

        socket.on "RPCSPAWNREQUEST", (data)=>
            @requestSpawn(data)

        socket.on "disconnect", ()=>
            @players.pop(socket)

    requestSpawn:(data)=>
        tag=data.tag
        id=@ids++
        clientId=data.clientId
        x=data.x
        y=data.y
        #console.log this
        switch tag
            when 0 then object = new Factory(tag, id, clientId,x,y, this)
            when 1 then object = new Robot(tag, id, clientId, x, y, this)
        @gameObjects[id]= object

        @players.forEach (player)->
            player.emit("RPCSPAWN", {tag:tag, id:id, clientId:clientId, x:x, y:y})



class Factory
    constructor:(tag, id, clientId, x, y, game)->
        @tag=tag
        @id=id
        @clientId=clientId
        @x=x
        @y=y
        @game=game
        @delay = 300
        @prev = 0
        @current = 0
        #console.log game
    update:(deltaTime)=>
        console.log "update"
        @current +=deltaTime
        if @current > @prev + @delay
            console.log "spawning"
            @game.requestSpawn({tag:1, clientId:@clientId, x:@x, y:@y})
            @prev=@current

class Robot
    constructor:(tag, id, clientId, x, y, game)->
        @tag=tag
        @id=id
        @clientId=clientId
        @x=x
        @y=y
        @game=game
        @speed = 1
        console.log game
    update:(deltaTime)=>
        enemies=@game.gameObjects.filter (x) => x.clientId!=@clientId
        if enemies.length > 0
            enemies.sort (a,b)->
                if Math.pow(@x-a.x,2)+Math.pow(@y-a.y,2)>Math.pow(@x-b.x,2)+Math.pow(@y-b.y,2) then 1 else -1
            target=enemies[0]
            console.log "targeting"
            console.log target.clientId


game= new Game()

#STEP 3: handle communication
io=require("socket.io").listen(server)
io.sockets.on "connection", (socket)->
    game.addPlayer socket

'''clients=0
io=require("socket.io").listen(server)
io.sockets.on "connection", (socket)->
    ids=0

    io.sockets.emit "NEWS", {news:"someone has joined us"}

    socket.emit "CONNECTED", {clientId:clients++}
    
    socket.on "RPCSPAWNREQUEST", (data)->
        socket.emit "RPCSPAWN", {x:data.x, y:data.y, tag:data.tag, id:ids++}
        console.log {x:data.x, y:data.y, tag:data.tag, id:ids}

    #socket.emit "RPCMOVE", {tag:0, id:ids-1, x: 500, y:500}
    
    socket.on "disconnect", ()->
        io.sockets.emit "NEWS", {news:"someone has left us"}
'''