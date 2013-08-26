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
  Q = window.Q = Quintus().include("Sprites, Scenes, Input, Audio, 2D, Anim, Touch, UI").setup(width: 768, height: 480).controls().touch()
  Q.input.mouseControls()
  Q.input.keyboardControls()
  Q.enableSound()
  Q.el.style.cursor = 'auto'

  Q.FloorHeight = 450
  Q.LevelWidth = 3840


  Q.Vector =
    subtract: (v1, v2) ->
      { x: v1.x - v2.x, y: v1.y - v2.y}
    distance: (v1, v2) ->
      Math.sqrt(Math.pow(v1.x - v2.x, 2) + Math.pow(v1.y - v2.y, 2))
      
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
      mouseDown = => @entity.trigger("mouseDown")
      Q.el.addEventListener.apply Q.el, ["mousedown", mouseDown, false]
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

  Q.component "sticker",
    added: ->
      @entity.on "step", this, "step"

    step: (dt) ->
      if @entity._stickerActive
        @entity.p.x = Q.inputs["mouseX"]
        @entity.p.y = Q.inputs["mouseY"]

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
        x: 400 # You can also set additional properties that can
        y: Q.FloorHeight# be overridden on object creation

      @p.y -= @p.h / 2
 
      @speed = 50
      if Q.DEBUG
        if Q.DEBUG.SPEED
          @speed = 600
     
      # Add in pre-made components to get up and running quickly
      # The `2d` component adds in default 2d collision detection
      # and kinetics (velocity, gravity)
      @add "2d, animation"
      @play "right"

      Q.input.on "left", this, @turnLeft
      Q.input.on "right", this, @turnRight

      # Write event handlers to respond hook into behaviors.
      # hit.sprite is called everytime the player collides with a sprite
      @on "hit.sprite", (collision) ->
        # Check the collision, if it's the Tower, you win!
        if collision.obj.isA("Tower")
          Q.stageScene "endGame", 1,
            label: "You Won!"
          @destroy()

    turnLeft: -> @play "left"
    turnRight: -> @play "right"

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

    distanceFromEnemy: (enemy) ->
      distance = 0
      if enemy.direction() == "left"
        distance = (enemy.p.x - enemy.range) - @p.x
      else
        distance = @p.x - (enemy.p.x + enemy.range)
      Math.abs(distance)

    checkEnemies: ->
      x = @p.x
      @closestEnemy = Infinity
      for enemy in @enemies
        enemyX = enemy.p.x
        turnedToPlayer = (enemy.direction() == "left" && x < enemyX) ||
        (enemy.direction() == "right" && x > enemyX)
        if turnedToPlayer
          newDistance = @distanceFromEnemy(enemy)
          if newDistance < @closestEnemy then @closestEnemy = newDistance
          if @visible && @withinRange(enemy, enemy.range)
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

      if @p.vx == 0
        @play "standing"

      @checkSpotLights()
      @checkEnemies()

    draw: (ctx)->
      @_super(ctx)
      if Q.DEBUG
        ctx.fillStyle = "rgba(0,255,255, 0.5)"
        ctx.fillRect(-@p.cx, 0, @p.w, 10)
        mousePoint = {x: Q.inputs["mouseX"], y: Q.inputs["mouseY"]}
        length = Q.Vector.distance(@p, mousePoint)
        difference = Q.Vector.subtract(mousePoint, @p)
        ctx.fillStyle = "grey"
        ctx.fillText("x: #{@p.x} y: #{@p.y}", 0, - 200)
        ctx.rotate(Math.atan2(difference.y, difference.x))
        ctx.fillRect(0, 0, length, 10)

  Q.Sprite.extend "ProximityAlert",
    init: (options) ->
      @_super options,
        asset: "exclamacao.png"
      @maximumAlert = 100
      @p.x = @p.player.p.x
      @p.y = (@p.player.p.y - @p.player.p.h/2) - @p.h/2

    step: (dt) ->
      @p.x = @p.player.p.x

    draw: (ctx) ->
      if @p.player.visible
        @p.asset = "exclamacao.png"
        @_super(ctx)
        ctx.globalAlpha = @maximumAlert / @p.player.closestEnemy
        @p.asset = "exclamacao_red.png"
        @_super(ctx)

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
        type: Q.SPRITE_NONE
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
      @play "right"

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

      if @direction() == "left" && @p.animation != "left"
        @play "left"
      else if @direction() == "right" && @p.animation != "right"
        @play "right"

  Q.Sprite.extend "MenuItem",
    init: (options) ->
      @_super options,
        type: Q.SPRITE_UI
      @offsetX = @p.x
      @offsetY = @p.y
      if options.sticker
        @add "extendedMouseEvents, sticker"
      else
        @add "extendedMouseEvents"
      @on "click", "click"
      @on "mouseEnter", -> Q.el.style.cursor = "pointer"
      @on "mouseLeave", -> Q.el.style.cursor = "auto"

    step: (dt) ->
      if ! @_stickerActive
        @p.x = Q.stage().viewport.x + @offsetX
        @p.y = @offsetY

    click: ->
      if Q.SelectedItem?
        if Q.SelectedItem == this
          if @p.useHandler
            @p.useHandler()
          if @_stickerActive
            @_stickerActive = false
          Q.SelectedItem = null
      else
        if @p.selectHandler
          @p.selectHandler()
        if @p.sticker
          @_stickerActive = true
        Q.SelectedItem = this
      
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

    teste: -> console.log("TESTE")

  Q.Sprite.extend "LevelCollider",
    init: (options) ->
      @_super options
      @leftWall = {
        p:
          w: 10
          h: 768
          x: 360
          y: 0
      }
      @rightWall =  {
        p:
          w: 10
          h: 768
          x: 3400
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
      x: Q.LevelWidth / 2
      y: 480 / 2
      type: 0
    }
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
    stage.insert new Q.ProximityAlert(player: player)

    # Give the stage a moveable viewport and tell it
    # to follow the player.
    stage.add("viewport").follow player, y: false, x: true
    
    stage.insert new Q.MenuItem(
      x: 60
      y: 70
      asset: "cellphone.png"
      sticker: true
    )
 
    stage.insert new Q.MenuItem(
      x: 200
      y: 70
      asset: "grampeador.png"
      sticker: true
    )
    # Add in a couple of enemies
    stage.insert new Q.Enemy(
      x: 900
      player: player
      left_limit: 500
      right_limit: 2000
      range: 200
    )

    spotLightOffset = 358
    spotLightDistance = 425
    nSpotLights = Math.floor((Q.LevelWidth - spotLightOffset) / spotLightDistance)
    for i in [0..nSpotLights]
      stage.insert new Q.SpotLight(
        x: spotLightOffset + spotLightDistance * i
        y: 430
        player: player
        range: 80
      )

    if ! Q.DEBUG
      Q.audio.play "bg.mp3", loop: true

  Q.Sprite.extend "Intro",
    init: (options) ->
      @_super options,
        x: 0
        y: 0
        cx: 0
        cy: 0

      @timer          = 0

      @frameCount     = 0
      @framesNames    = ["escritorio_luz.png", "escritorio.png", "escritorio_apagado.png", "escritorio_assassinato.png"]
      @frameEvents    = [1, 2, 3, 4, 5, 6, 7, 8, 9,13]
      @framePerEvent  = [0, 1, 0, 1, 0, 1, 0, 1, 2, 3]
      @frameChanged   = false

      @audioCount     = 0
      @audioEvents    = [0, 1, 13]
      @audioPerEvent  = ["cello.mp3", "train.mp3", "brokenString.mp3"]
      @audioChanged   = false

    step: (dt) ->
      @timer += dt
      if @frameCount < @frameEvents.length && @timer >= @frameEvents[@frameCount]
        @p.asset = @framesNames[@framePerEvent[@frameCount]]
        console.log @p.asset
        @frameCount++

      if @audioCount < @audioEvents.length && @timer >= @audioEvents[@audioCount]
        console.log "AUDIO: " + @audioPerEvent[@audioCount]
        console.log "Timer: #{@timer}"
        Q.audio.play @audioPerEvent[@audioCount]
        @audioCount++

  Q.scene "intro", (stage) ->
    stage.insert new Q.Intro()

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

   Q.DEBUG = {
    SPEED: true
    IDCLIP: true
  }
  Q.debug = true
  Q.debug = false
  Q.DEBUG = false
  assets = "escritorio.png, escritorio_luz.png, escritorio_apagado.png, escritorio_assassinato.png, exclamacao.png, exclamacao_red.png, enemy_1.png, player.png, corredor.png, grampeador.png, key.png, cellphone.png"
  if ! Q.debug
    assets += ", bg.mp3, cello.mp3, train.mp3, brokenString.mp3"
  # ## Asset Loading and Game Launch
  # Q.load can be called at any time to load additional assets
  # assets that are already loaded will be skipped
  # The callback will be triggered when everything is loaded
  Q.load assets, ->
    

    Q.gravityY = 0
    Q.input.keyboardControls
      65: "left"  # A
      68: "right" # D

    Q.sheet "player", "player.png",
      tilew: 105
      tileh: 123
      sx: 0
      sy: 0

    Q.sheet "enemy_1", "enemy_1.png",
      tilew: 70
      tileh: 128

    Q.animations "player",
      standing:
        frames: [28]
        rate: 1
      right:
        frames: [0..13]
        rate: 1/5
      left:
        frames: [14..27]
        rate: 1/5

    Q.animations "enemy_1",
      right:
        frames: [0..2]
        rate: 1/3
      left:
        frames: [3..5]
        rate: 1/3
    
    # Finally, call stageScene to run the game
    Q.stageScene "intro"#"level1"
  , progressCallback: (loaded, total) ->
      element = document.getElementById("loading_progress")
      element.style.width = Math.floor(loaded/total*100) + "%"
      if loaded == total
        document.getElementById("loading").style.display = "none"

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

