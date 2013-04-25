// Generated by CoffeeScript 1.6.2
(function() {
  var Network,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $(window).load(function() {
    var net;

    return net = new Network();
  });

  Network = (function() {
    Network.prototype.gameObjects = [];

    function Network() {
      this.spawn = __bind(this.spawn, this);
      var bitMap, canvas, socket,
        _this = this;

      canvas = document.getElementById("Canvas");
      canvas.width = 1000;
      canvas.height = 1000;
      this.stage = new createjs.Stage(canvas);
      createjs.Ticker.setFPS(20);
      createjs.Ticker.addEventListener("tick", function(ev) {
        return _this.stage.update();
      });
      this.robotContainer = new createjs.Container();
      this.factoryContainer = new createjs.Container();
      this.stage.addChild(this.factoryContainer);
      this.stage.addChild(this.robotContainer);
      bitMap = new createjs.Bitmap("images/capitol.png");
      bitMap.scaleX = 0.1;
      bitMap.scaleY = 0.1;
      this.stage.addChild(bitMap);
      socket = io.connect("localhost");
      socket.on("CONNECTED", function(data) {
        alert("connected with clientId" + data.clientId);
        return _this.selfId = data.clientId;
      });
      socket.on("NEWS", function(data) {
        return alert(data.news);
      });
      socket.on("RPCSPAWN", function(data) {
        alert("RPCSPAWN");
        return _this.spawn(data);
      });
      socket.on("RPCMOVE", function(data) {
        var id, object, tag, x, y, _i, _len, _ref, _results;

        id = data.id;
        tag = data.tag;
        x = data.x;
        y = data.y;
        _ref = _this.gameObjects;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          object = _ref[_i];
          if (object.id === id && object.tag === tag) {
            object.x = x;
            object.y = y;
            object.shape.x = x;
            _results.push(object.shape.y = y);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      window.onmousedown = function(ev) {
        var mx, my;

        mx = _this.stage.mouseX;
        my = _this.stage.mouseY;
        return socket.emit("RPCSPAWNREQUEST", {
          x: mx,
          y: my,
          tag: 0,
          clientId: _this.selfId
        });
      };
    }

    Network.prototype.spawn = function(data) {
      var bitMap, id, tag, x, y;

      alert("spawn");
      x = data.x;
      y = data.y;
      id = data.id;
      tag = data.tag;
      bitMap = null;
      if (tag === 0) {
        bitMap = new createjs.Bitmap("images/gears.png");
        bitMap.regX = 25;
        bitMap.regY = 25;
        bitMap.scaleX = 0.1;
        bitMap.scaleY = 0.1;
        this.factoryContainer.addChild(bitMap);
      } else if (tag === 1) {
        bitMap = new createjs.Bitmap("images/vintage-robot.png");
        bitMap.regX = 10;
        bitMap.regY = 10;
        bitMap.scaleX = 0.04;
        bitMap.scaleY = 0.04;
        this.robotContainer.addChild(bitMap);
      } else {
        alert("someone messed up the tags. remember that mines are not implemented on the client yet.");
      }
      this.stage.update();
      bitMap.x = x;
      bitMap.y = y;
      return this.gameObjects.push({
        shape: bitMap,
        x: x,
        y: y,
        tag: data.tag,
        id: data.id,
        clientId: data.clientId
      });
    };

    return Network;

  })();

}).call(this);

/*
//@ sourceMappingURL=game.map
*/
