// Generated by CoffeeScript 1.3.3
(function() {

  window.addEventListener("load", function() {
    var Q;
    Q = window.Q = Quintus().include("Sprites, Scenes, Input, 2D, Anim, Touch, UI").setup({
      maximize: true
    }).controls().touch();
    Q.Sprite.extend("Player", {
      init: function(p) {
        this._super(p, {
          sheet: "player",
          x: 410,
          y: 90
        });
        this.speed = 200;
        this.add("2d");
        Q.input.on("fire", this, "action");
        return this.on("hit.sprite", function(collision) {
          if (collision.obj.isA("Tower")) {
            Q.stageScene("endGame", 1, {
              label: "You Won!"
            });
            return this.destroy();
          }
        });
      },
      isVisible: function() {
        return true;
      },
      busted: function() {
        return console.log("busted!");
      },
      step: function(dt) {
        if (Q.inputs["left"]) {
          this.p.vx = -this.speed;
          return this.p.direction = "left";
        } else if (Q.inputs["right"]) {
          this.p.vx = this.speed;
          return this.p.direction = "right";
        } else {
          return this.p.vx = 0;
        }
      },
      action: function() {
        return console.log("action!");
      }
    });
    Q.Sprite.extend("Tower", {
      init: function(p) {
        return this._super(p, {
          sheet: "tower"
        });
      }
    });
    Q.Sprite.extend("LightSpot", {
      init: function(options) {
        this._super(options);
        return this.player = options["player"];
      }
    });
    Q.Sprite.extend("Enemy", {
      init: function(options) {
        this._super(options, {
          sheet: "enemy",
          vx: -100
        });
        this.player = options["player"];
        this.left_limit = options["left_limit"];
        this.right_limit = options["right_limit"];
        this.speed = options["speed"] || 100;
        this.range = options["range"] || 200;
        console.log(this.speed);
        return this.add("2d");
      },
      direction: function() {
        if (this.p.vx < 0) {
          return "left";
        } else {
          return "right";
        }
      },
      canSeePlayer: function() {
        var playerX, turnedToPlayer, withinRange, x;
        x = this.p.x;
        playerX = this.player.p.x;
        turnedToPlayer = (this.direction() === "left" && playerX < x) || (this.direction() === "right" && playerX > x);
        withinRange = Math.abs(playerX - x) <= this.range;
        return turnedToPlayer && withinRange;
      },
      step: function(dt) {
        var new_vx, new_x;
        new_x = this.p.x + this.p.vx * dt;
        new_vx = this.p.vx === 0 ? this.speed : this.p.vx;
        if (this.direction() === "left" && new_x <= this.left_limit) {
          new_vx = this.speed;
        }
        if (this.direction() === "right" && new_x >= this.right_limit) {
          new_vx = -this.speed;
        }
        this.p.vx = new_vx;
        if (this.player.isVisible() && this.canSeePlayer()) {
          return this.player.busted();
        }
      }
    });
    Q.scene("level1", function(stage) {
      var level_json, player;
      stage.insert(new Q.Repeater({
        asset: "background-wall.png",
        speedX: 0.5,
        speedY: 0.5
      }));
      level_json = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]];
      stage.collisionLayer(new Q.TileLayer({
        dataAsset: level_json,
        sheet: "tiles"
      }));
      player = stage.insert(new Q.Player());
      stage.add("viewport").follow(player);
      stage.insert(new Q.Enemy({
        x: 700,
        y: 0,
        player: player,
        left_limit: 500,
        right_limit: 750
      }));
      return stage.insert(new Q.Tower({
        x: 180,
        y: 50
      }));
    });
    Q.scene("endGame", function(stage) {
      var button, container, label;
      container = stage.insert(new Q.UI.Container({
        x: Q.width / 2,
        y: Q.height / 2,
        fill: "rgba(0,0,0,0.5)"
      }));
      button = container.insert(new Q.UI.Button({
        x: 0,
        y: 0,
        fill: "#CCCCCC",
        label: "Play Again"
      }));
      label = container.insert(new Q.UI.Text({
        x: 10,
        y: -10 - button.p.h,
        label: stage.options.label
      }));
      button.on("click", function() {
        Q.clearStages();
        return Q.stageScene("level1");
      });
      return container.fit(20);
    });
    return Q.load("sprites.png, tiles.png, background-wall.png, sprites.json", function() {
      Q.sheet("tiles", "tiles.png", {
        tilew: 32,
        tileh: 32
      });
      Q.compileSheets("sprites.png", "sprites.json");
      return Q.stageScene("level1");
    });
  });

}).call(this);
