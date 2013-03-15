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
        
        @testshape= new createjs.Shape()
        @testshape.graphics.beginFill("#951")
        @testshape.graphics.drawRect(50,50,50,50)
        
        @stage.addChild(@testshape)
        @stage.update()
        
        createjs.Ticker.setFPS(20);
        createjs.Ticker.addEventListener "tick", (ev)=>
            @stage.update()
        
        socket=io.connect "localhost"

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
            socket.emit "RPCSPAWNREQUEST", (x:mx, y:my, tag:0)
            
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