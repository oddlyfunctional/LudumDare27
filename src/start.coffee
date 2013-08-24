window.addEventListener "load", ->
  console.log("Start")
  Q.load "sprites.png,  tiles.png, background-wall.png", ->
    console.log("loaded")
    Q.sheet("tiles","tiles.png", { tilew: 32, tileh: 32 })
    sprites ={"player":{"sx":0,"sy":0,"cols":1,"tilew":30,"tileh":30,"frames":1},"enemy":{"sx":0,"sy":30,"cols":1,"tilew":30,"tileh":24,"frames":1},"tower":{"sx":0,"sy":54,"cols":1,"tilew":30,"tileh":30,"frames":1}}
    Q.compileSheets "sprites.png", sprites
    Q.stageScene "level1"

