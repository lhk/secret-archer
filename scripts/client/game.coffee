$(window).load ->
    net = new Network()
    

class Network
    gameObjects:[]
    constructor: ->
        canvas= document.getElementById("Canvas")
        alert(canvas)
        canvas.width=1000
        canvas.height=1000
        @stage= new createjs.Stage(canvas)
        alert(@stage)
        
        createjs.Ticker.setFPS(20);
        createjs.Ticker.addEventListener "tick", (ev)=>
            @stage.update()
        
        socket=io.connect "localhost"

        socket.on "CONNECTED", (data)=>
            alert "connected with clientId"+data.clientId
            @selfId=data.clientId

        socket.on "NEWS", (data)->
            alert data.news
        
        socket.on "RPCSPAWN", (data)=>
            alert "RPCSPAWN"
            @spawn(data)

        socket.on "RPCMOVE", (data)=>
            alert "RPCMOVE"
            #parse the message
            id= data.id
            tag= data.tag
            x= data.x
            y= data.y
            #identify the right object
            for object in @gameObjects
                if object.id==id and object.tag == tag
                    object.x=x
                    object.y=y
                    object.shape.x=x
                    object.shape.y=y
        
        window.onmousedown= (ev)=>
            mx=@stage.mouseX
            my=@stage.mouseY
            socket.emit "RPCSPAWNREQUEST", (x:mx, y:my, tag:0, clientId:@selfId)
            
    spawn: (data)=>
        x=data.x
        y=data.y
        
        
        shape= new createjs.Shape()
        shape.graphics.beginFill("#555")
        shape.graphics.drawRect(-25,-25,50,50)
        @stage.addChild(shape)
        @stage.update()
        
        @gameObjects.push({shape:shape, x:x, y:y, tag:data.tag, id:data.id})
        shape.x=x
        shape.y=y
        alert ""+data.id+","+data.tag