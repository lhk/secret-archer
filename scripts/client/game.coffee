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
        
        
        window.onmousedown= (ev)=>
            alert "click"
            mx=@stage.mouseX
            my=@stage.mouseY
            @spawn({x:mx,y:my})
            
    spawn: (data)=>
        x=data.x
        y=data.y
        
        
        shape= new createjs.Shape()
        shape.graphics.beginFill("#555")
        shape.graphics.drawRect(x-25,y-25,50,50)
        @stage.addChild(shape)
        @stage.update()