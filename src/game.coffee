#window.addEventListener "load", ->

#window.Q = Quintus({ development: true }).include("Sprites, Scenes, Input, 2D, Anim, Touch, UI").setup(width: 1280, height: 768).controls().touch()

# # Quintus platformer example
#
# [Run the example](../examples/platformer/index.html)
# WARNING: this game must be run from a non-file:// url
# as it loads a level json file.
#
# This is the example from the website homepage, it consists
# a simple, non-animated platformer with some enemies and a 
# target for the player.
window.addEventListener "load", ->
  
  # Set up an instance of the Quintus engine  and include
  # the Sprites, Scenes, Input and 2D module. The 2D module
  # includes the `TileLayer` class as well as the `2d` componet.
  
  # Maximize this game to whatever the size of the browser is
  
  # And turn on default input controls and touch input (for UI)
  Q = window.Q = Quintus().include("Sprites, Scenes, Input, 2D, Anim, Touch, UI").setup(width: 768, height: 480).controls().touch()
  Q.input.mouseControls()
  Q.input.keyboardControls()
  Q.el.style.cursor = 'auto'

  Q.FloorHeight = 450

  Q.pointInside = (point, o) ->
    c = o.c || o.p

    ox = c.x - c.cx
    oy = c.y - c.cy

    !((oy+c.h<=point.y) || (oy>=point.y) ||
      (ox+c.w<=point.x) || (ox>=point.x))

  Q.component "extendedMouseEvents",
    mouseInside: ->
      mouseX = Q.inputs["mouseX"]
      mouseY = Q.inputs["mouseY"]
      Q.pointInside({x: mouseX, y: mouseY}, @entity)

    added: ->
      mouseClick = => if @mouseInside() then @entity.trigger("click")
      Q.el.addEventListener.apply Q.el, ["mousedown", mouseClick, false]
      mouseEnter = =>
        if !@inside && @mouseInside()
          @inside = true
          @entity.trigger("mouseEnter")
      Q.el.addEventListener.apply Q.el, ["mousemove", mouseEnter, false]
      mouseLeave = =>
        if @inside && !@mouseInside()
          @inside = false
          @entity.trigger("mouseLeave")
      Q.el.addEventListener.apply Q.el, ["mousemove", mouseLeave, false]

  # ## Player Sprite
  # The very basic player sprite, this is just a normal sprite
  # using the player sprite sheet with default controls added to it.
  Q.Sprite.extend "Player",
    
    click: -> console.log("click")
    hover: -> console.log("hover")
    # the init constructor is called on creation
    init: (p) ->
      
      # You can call the parent's constructor with this._super(..)
      @_super p,
        sheet: "player" # Setting a sprite sheet sets sprite width and height
        sprite: "player"
        x: 100 # You can also set additional properties that can
        y: Q.FloorHeight# be overridden on object creation

      @p.y -= @p.h / 2
      @speed = 200

      # Add in pre-made components to get up and running quickly
      # The `2d` component adds in default 2d collision detection
      # and kinetics (velocity, gravity)
      @add "2d, animation"

      Q.input.on "fire", this, "action"
      
      # Write event handlers to respond hook into behaviors.
      # hit.sprite is called everytime the player collides with a sprite
      @on "hit.sprite", (collision) ->
        # Check the collision, if it's the Tower, you win!
        if collision.obj.isA("Tower")
          Q.stageScene "endGame", 1,
            label: "You Won!"
          @destroy()

    busted: -> console.log("busted!")

    addSpotLight: (spotLight) ->
      @spotLights ||= []
      @spotLights.push(spotLight)

    addEnemy: (enemy) ->
      @enemies ||= []
      @enemies.push(enemy)

    withinRange: (object, range)->
      Math.abs(@p.x - object.p.x) <= range

    checkSpotLights: ->
      @visible = false
      for spotLight in @spotLights
        if @withinRange(spotLight, spotLight.range)
          @visible = true

    checkEnemies: ->
      x = @p.x
      for enemy in @enemies
        enemyX = enemy.p.x
        turnedToPlayer = (enemy.direction() == "left" && x < enemyX) ||
        (enemy.direction() == "right" && x > enemyX)
        if turnedToPlayer
          if @visible && @withinRange(enemy, enemy.range) || @withinRange(enemy, enemy.flashlightRange)
            @busted()

    step: (dt) ->
      if Q.inputs["left"]
        @p.vx = -@speed
        @p.direction = "left"
      else if Q.inputs["right"]
        @p.vx = @speed
        @p.direction = "right"
      else
        @p.vx = 0

      @checkSpotLights()
      @checkEnemies()

    draw: (ctx)->
      @_super(ctx)
      ctx.fillStyle = "rgb(0,255,255)"
      ctx.fillRect(-@p.cx, 0, @p.w, 10)
    action: ->
      console.log("action!")

  
  # ## Tower Sprite
  # Sprites can be simple, the Tower sprite just sets a custom sprite sheet
  Q.Sprite.extend "Tower",
    init: (p) ->
      @_super p,
        sheet: "tower"

  Q.Sprite.extend "SpotLight",
    init: (options) ->
      @_super options
      @range = options["range"] || 100
      options["player"].addSpotLight(this)

    draw: (ctx)->
      @_super(ctx)
      if Q.DEBUG
        ctx.fillStyle = "yellow"
        ctx.fillRect(- @range, 0, @range * 2, 10)


  # ## Enemy Sprite
  # Create the Enemy class to add in some baddies
  Q.Sprite.extend "Enemy",
    init: (options) ->
      @_super options,
        sprite: "enemy_1"
        sheet: "enemy_1"
        y: Q.FloorHeight
        vx: -100
      @p.y -= @p.h / 2
      @left_limit = options["left_limit"]
      @right_limit = options["right_limit"]
      @speed = options["speed"] || 100
      @range = options["range"] || 200
      @flashlightRange = options["flashlightRange"] || 100
      options["player"].addEnemy(this)
      
      # Enemies use the Bounce AI to change direction 
      # whenver they run into something.
      @add "2d, animation"
      @play "walking"

    direction: ->
      if @p.vx < 0
        "left"
      else
        "right"

    draw: (ctx) ->
      @_super(ctx)
      if Q.DEBUG
        ctx.fillStyle = "blue"
        if @direction() == "left"
          ctx.fillRect(- @range, 0, @range, 10)
        else
          ctx.fillRect(0, 0, @range, 10)
        ctx.fillStyle = "red"
        if @direction() == "left"
          ctx.fillRect(- @flashlightRange, 0, @flashlightRange, 10)
        else
          ctx.fillRect(0, 0, @flashlightRange, 10)

    step: (dt) ->
      new_x = @p.x + @p.vx * dt
      new_vx = if @p.vx == 0 then @speed else @p.vx
      if (@direction() == "left" && new_x <= @left_limit)
        new_vx = @speed
      if (@direction() == "right" && new_x >= @right_limit)
        new_vx = -@speed
      @p.vx = new_vx

  Q.Sprite.extend "Door",
    init: (options) ->
      @_super options,
        y: Q.FloorHeight - 79
        h: 123
        w: 95
        type: 0
      @on "phonecall", "ring"
      @on "click", "teste"
      @add "extendedMouseEvents"
      console.log 'door'
      console.log @p

    teste: -> console.log("TESTE")
    draw: (ctx)->
      @_super(ctx)
      if Q.DEBUG
        ctx.fillStyle = "green"
        ctx.fillRect(-@p.cx, -@p.cy, @p.w, @p.h)

  Q.Sprite.extend "LevelCollider",
    init: (options) ->
      @_super options
      @leftWall = {
        p:
          w: 10
          h: 768
          x: 0
          y: 0
      }
      @rightWall =  {
        p:
          w: 10
          h: 768
          x: 1280
          y: 0
      }

    collide: (obj) ->
      Q.collision(obj, @leftWall) || Q.collision(obj, @rightWall)
      

  # ## Level1 scene
  # Create a new scene called level 1
  Q.scene "level1", (stage) ->
    
    # Add in a repeater for a little parallax action
    #stage.insert new Q.Repeater(
    #  asset: "corredor.png"
    #  repeatY: false
    #  repeatX: true
    #  y: 0
    #)
    window.bg = new Q.Sprite {
      asset: "corredor.png"
      x: 800 / 2
      y: 480 / 2
      type: 0
    }
    console.log bg
    stage.insert bg
    # Add in a tile layer, and make it the collision layer
    stage.collisionLayer new Q.LevelCollider()
    #new Q.TileLayer(
    #  dataAsset: level_json,
    #  sheet: "tiles"
    #)
    stage.insert new Q.Door(x: 207)
    
    # Create the player and add them to the stage
    window.player = stage.insert(new Q.Player())
    player.play("walking_right")
    
    # Give the stage a moveable viewport and tell it
    # to follow the player.
    stage.add("viewport").follow player, y: false, x: true
    
    # Add in a couple of enemies
    stage.insert new Q.Enemy(
      x: 700
      player: player
      left_limit: 500
      right_limit: 750
      range: 200
    )

    spotLightOffset = 372
    spotLightDistance = 302
    for i in [0..2]
      stage.insert new Q.SpotLight(
        x: spotLightOffset + spotLightDistance * i
        y: 430
        player: player
        range: 82
      )
  
  # To display a game over / game won popup box, 
  # create a endGame scene that takes in a `label` option
  # to control the displayed message.
  Q.scene "endGame", (stage) ->
    container = stage.insert(new Q.UI.Container(
      x: Q.width / 2
      y: Q.height / 2
      fill: "rgba(0,0,0,0.5)"
    ))
    button = container.insert(new Q.UI.Button(
      x: 0
      y: 0
      fill: "#CCCCCC"
      label: "Play Again"
    ))
    label = container.insert(new Q.UI.Text(
      x: 10
      y: -10 - button.p.h
      label: stage.options.label
    ))
    
    # When the button is clicked, clear all the stages
    # and restart the game.
    button.on "click", ->
      Q.clearStages()
      Q.stageScene "level1"

    
    # Expand the container to visibily fit it's contents
    # (with a padding of 20 pixels)
    container.fit 20

  
  # ## Asset Loading and Game Launch
  # Q.load can be called at any time to load additional assets
  # assets that are already loaded will be skipped
  # The callback will be triggered when everything is loaded
  Q.load "sprites.png, enemy_1.png, player_front.png, player.png, tiles.png, corredor.png, sprites.json", ->
    
    Q.DEBUG = true
    Q.debug = true
    Q.gravityY = 0
    Q.input.keyboardControls
      65: "left"  # A
      68: "right" # D

    #Q.sheet "player_front", "player_front.png",
    #  tilew: 35
    #  tileh: 118
    #  sx: 0
    #  sy: 0

    Q.sheet "player", "player.png",
      tilew: 95
      tileh: 112
      sx: 1
      sy: 0

    Q.sheet "enemy_1", "enemy_1.png",
      tilew: 70
      tileh: 128

    Q.animations "player",
      walking_left:
        frames: [0..13]
        rate: 1/2
      walking_right:
        frames: [14..26]
        rate: 1/2

    Q.animations "enemy_1",
      walking:
        frames: [0..2]
        rate: 1/3
    
    # Finally, call stageScene to run the game
    Q.stageScene "level1"

# ## Possible Experimentations:
# 
# The are lots of things to try out here.
# 
# 1. Modify level.json to change the level around and add in some more enemies.
# 2. Add in a second level by creating a level2.json and a level2 scene that gets
#    loaded after level 1 is complete.
# 3. Add in a title screen
# 4. Add in a hud and points for jumping on enemies.
# 5. Add in a `Repeater` behind the TileLayer to create a paralax scrolling effect.  

