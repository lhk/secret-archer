$(window).load ->
    net = new Network()
    

class Network
    gameObjects:[]
    constructor: ->
        canvas= document.getElementById("Canvas")
        #alert(canvas)
        canvas.width=1000
        canvas.height=1000
        @stage= new createjs.Stage(canvas)
        #alert(@stage)
        
        createjs.Ticker.setFPS(20);
        createjs.Ticker.addEventListener "tick", (ev)=>
            @stage.update()

        @robotContainer= new createjs.Container()
        @factoryContainer= new createjs.Container()

        @stage.addChild(@factoryContainer)
        
        @stage.addChild(@robotContainer)

        bitMap= new createjs.Bitmap("images/capitol.png")
        bitMap.scaleX=0.1
        bitMap.scaleY=0.1

        @stage.addChild(bitMap)
        
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
            #alert "RPCMOVE"
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
        alert "spawn"
        x=data.x
        y=data.y
        
        id=data.id
        tag=data.tag

        #shape= new createjs.Shape()
        bitMap= null

        if tag == 0
            #alert "factory"
            #shape.graphics.beginFill("#555")
            #shape.graphics.drawRect(-25,-25,50,50)
            #@factoryContainer.addChild(shape)
            bitMap=new createjs.Bitmap("images/gears.png")
            bitMap.regX= 25
            bitMap.regY= 25
            bitMap.scaleX=0.1
            bitMap.scaleY=0.1
            @factoryContainer.addChild(bitMap)
        else if tag == 1
            #alert "robot"
            #shape.graphics.beginFill("#000")
            #shape.graphics.drawRect(-5,-5,10,10)
            #@robotContainer.addChild(shape)
            bitMap=new createjs.Bitmap("images/vintage-robot.png")
            bitMap.regX= 10
            bitMap.regY= 10
            bitMap.scaleX=0.04
            bitMap.scaleY=0.04
            @robotContainer.addChild(bitMap)
        else
            alert "someone messed up the tags. remember that mines are not implemented on the client yet."
        #@stage.addChild(shape)
        @stage.update()
        
        #@gameObjects.push({shape:shape, x:x, y:y, tag:data.tag, id:data.id})
        #shape.x=x
        #shape.y=y
        #alert "id "+data.id+", tag "+data.tag
        bitMap.x=x
        bitMap.y=y
        @gameObjects.push({shape:bitMap, x:x, y:y, tag:data.tag, id:data.id, clientId:data.clientId})