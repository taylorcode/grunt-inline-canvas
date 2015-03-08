window.CanvasVideo = (($, Promise) ->

  imgPromise = (src) ->  
    new Promise (resolve, reject) ->
      img = new Image
      img.src = src
      resolve img if img.complete # if already loaded (cached) then resolve
      img.onload = ->
        resolve @
      img.onerror = ->
        reject @

  CanvasVideo = (canvas, base64File, options) ->
    @options = _.extend @options, options
    @ctx = canvas.getContext '2d'
    @images = []
    @frame = 0
    @paused = true
    @_playing = false
    @base64File = base64File
    @load().then => @play()
    @

  # default options
  CanvasVideo::options =
    frameRate: 30
    width: 400
    height: 300
    imageEncoding: 'png'

  # Re-loads the video element
  # requests the base64file, loads all images, assigns @images, returns a promise resolving with the images
  CanvasVideo::load = ->
    # jQuery promises are broken, so use callback and wrap in Promise
    fileLoad = new Promise (resolve, reject) =>
      $.get @base64File, (dataUris) =>
        imgPromises = []
        # load will reload all images from base64 data
        _.each dataUris.frames, (base64) => 
          imgPromises.push imgPromise 'data:image/' + @options.imageEncoding + ';base64,' + base64
        resolve imgPromises

    fileLoad.then (imgPromises) =>
      Promise.all(imgPromises).then (images) =>
        @_loaded = true
        @images = images # assign images to refiring of load

  CanvasVideo::_draw = (frame) ->
    # this conditional is better in play
    frame = @frame = 0 if not @images[frame]
    @ctx.drawImage @images[frame], 0, 0, @options.width, @options.height

  # Starts playing the video
  CanvasVideo::play = ->
    @paused = false
    return if @_playing or not @_loaded # do nothing if already playing
    (drawLoop = =>
        @_playing = true
        @_draw @frame
        @frame++

        @timeout = setTimeout =>
          drawLoop()
        , 1000 / @options.frameRate
    )()
    return

  # Pauses the currently playing video
  CanvasVideo::pause = ->
    @paused = true
    @_playing = false
    clearTimeout @timeout
    return

  CanvasVideo

) jQuery, Promise
