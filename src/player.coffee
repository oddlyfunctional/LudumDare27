window.addEventListener "load", ->
  Q.Sprite.extend "Player", -> {
    teste: ->
      console.log "wtf"
    init: (p)->
      console.log "Player!"
      this._super p,
        sheet: "player",
        x: 410,
        y: 90

      this.add("2d, platformerControls")

  }
  
