$(window).load ->
    game.init()
    

game=
    gameObjects:{}
    init: ->
        canvas= document.getElementById("Canvas")
        alert(canvas)
        @stage= new createjs.Stage(canvas)
        alert(@stage)
        
        @testshape= new createjs.Shape()
        @testshape.graphics.beginFill("#555")
        @testshape.graphics.rect(50,50,500,500)
        
        @stage.addChild(@testshape)
        @stage.update()