window.addEventListener "load", ->
  window.Q = Quintus({ development: true }).include("Sprites, Scenes, Input").setup
    width: 1280,
    height: 768



