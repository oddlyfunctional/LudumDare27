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
  Q = window.Q = Quintus().include("Sprites, Scenes, Input, 2D, Anim, Touch, UI").setup(maximize: true).controls().touch()

  # ## Player Sprite
  # The very basic player sprite, this is just a normal sprite
  # using the player sprite sheet with default controls added to it.
  Q.Sprite.extend "Player",
    
    # the init constructor is called on creation
    init: (p) ->
      
      # You can call the parent's constructor with this._super(..)
      @_super p,
        sheet: "player" # Setting a sprite sheet sets sprite width and height
        x: 410 # You can also set additional properties that can
        y: 90 # be overridden on object creation

      @speed = 200

      # Add in pre-made components to get up and running quickly
      # The `2d` component adds in default 2d collision detection
      # and kinetics (velocity, gravity)
      @add "2d"

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

    withinRange: (object)->
      Math.abs(@p.x - object.p.x) <= object.range

    checkSpotLights: ->
      @visible = false
      for spotLight in @spotLights
        if @withinRange(spotLight)
          @visible = true

    checkEnemies: ->
      x = @p.x
      for enemy in @enemies
        enemyX = enemy.p.x
        turnedToPlayer = (enemy.direction() == "left" && x < enemyX) ||
        (enemy.direction() == "right" && x > enemyX)
        if @visible && turnedToPlayer && @withinRange(enemy)
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
      console.log("Visible: " + @visible)
      @checkEnemies()

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
      @_super options,
        sheet: "tower"
      @range = options["range"] || 100
      options["player"].addSpotLight(this)

  # ## Enemy Sprite
  # Create the Enemy class to add in some baddies
  Q.Sprite.extend "Enemy",
    init: (options) ->
      @_super options,
        sheet: "enemy"
        vx: -100
      @left_limit = options["left_limit"]
      @right_limit = options["right_limit"]
      @speed = options["speed"] || 100
      @range = options["range"] || 200
      options["player"].addEnemy(this)
      
      # Enemies use the Bounce AI to change direction 
      # whenver they run into something.
      @add "2d"

    direction: ->
      if @p.vx < 0
        "left"
      else
        "right"

    step: (dt) ->
      new_x = @p.x + @p.vx * dt
      new_vx = if @p.vx == 0 then @speed else @p.vx
      if (@direction() == "left" && new_x <= @left_limit)
        new_vx = @speed
      if (@direction() == "right" && new_x >= @right_limit)
        new_vx = -@speed
      @p.vx = new_vx
  
  # ## Level1 scene
  # Create a new scene called level 1
  Q.scene "level1", (stage) ->
    
    # Add in a repeater for a little parallax action
    stage.insert new Q.Repeater(
      asset: "background-wall.png"
      speedX: 0.5
      speedY: 0.5
    )
    
    level_json = [
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    ]
    # Add in a tile layer, and make it the collision layer
    stage.collisionLayer new Q.TileLayer(
      dataAsset: level_json,
      sheet: "tiles"
    )
    
    # Create the player and add them to the stage
    player = stage.insert(new Q.Player())
    
    # Give the stage a moveable viewport and tell it
    # to follow the player.
    stage.add("viewport").follow player
    
    # Add in a couple of enemies
    stage.insert new Q.Enemy(
      x: 700
      y: 0
      player: player
      left_limit: 500
      right_limit: 750
      range: 200
    )

    stage.insert new Q.SpotLight(
      x: 400
      y: 50
      player: player
      range: 100
    )
 
    stage.insert new Q.SpotLight(
      x: 0
      y: 50
      player: player
      range: 100
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
  Q.load "sprites.png, tiles.png, background-wall.png, sprites.json", ->
    
    # Sprites sheets can be created manually
    Q.sheet "tiles", "tiles.png",
      tilew: 32
      tileh: 32

    # Or from a .json asset that defines sprite locations
    Q.compileSheets "sprites.png", "sprites.json"
    
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

