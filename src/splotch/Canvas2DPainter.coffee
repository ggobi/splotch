define ["cs!splotch/utils", "splotch/Transform"], (utils, Transform) ->
  
  class Canvas2DPainter extends CanvasPainter
  
    _dataTransform: new Transform
    _strokeStyle: "rgba(0, 0, 0, 1)"
    _fillStyle: "rgba(0, 0, 0, 1)"
    _glyphExpansion: 1.0
    
    constructor: (canvas) ->
      @context = canvas.getContext("2d")
      @_disableImageSmoothing()

    dataTransform: (dataTransform) ->
      if dataTransform?
        @context.setTransform(dataTransform)
        @_dataTransform = dataTransform
        this
      else @_dataTransform

    strokeStyle: (style) ->
      if style is undefined
        @_strokeStyle
      else
        if style isnt null
          @context.strokeStyle = style
        @_strokeStyle = style
        this
    
    fillStyle: (style) ->
      if style is undefined
        @_fillStyle
      else
        if style isnt null
          @context.fillStyle = style
        @_fillStyle = style
        this
      
    # FiXME: dashed lines are not supported until v5  
    # dash: (dash) ->
    #   @context.dash(dash) 

    lineWidth: (lineWidth) ->
      if lineWidth?
        @context.lineWidth = lineWidth
        this
      else @context.lineWidth

    glyphExpansion: (glyphExpansion) ->
      if glyphExpansion?
        @_glyphExpansion = glyphExpansion
        this
      else @_glyphExpansion
    
    font: (font) ->
      if font?
        @context.font = font
        this
      else @context.font
  
    textHAlign: (align) ->
      if align?
        @context.textAlign = align
        this
      else @context.textAlign
  
    textVAlign: (align) ->
      if align?
        @context.textBaseline = align
        this
      else @context.textBaseline
  
    strWidth: (string) ->
      @context.measureText(string).width

    _fontSize: () ->
      @font().match(/\ ([0-9]*)px /g)[0]
     
    strHeight: (string) ->
      _fontSize()
  
    polypath: (x, y, group = null, stroke = null, fill = null, close = false)->
      [x, y, group, stroke, fill] =
       utils.recycleArrays(x, y, group, stroke, fill)
      if x.length == 1
        throw "there must be at least two points for a line"

      for xi,i in x
        newFill = fill?[i] isnt @fillStyle()
        newStroke = stroke?[i] isnt @strokeStyle()
        
        if newFill
          @context.fill()
          @fillStyle(fill[i])

        if newStroke
          @context.stroke()
          @strokeStyle(stroke[i])

        if newFill or newStroke
          @context.beginPath()

        [px, py] = @_dataTransform.transformPoint(xi, y[i])
        
        if group is null or group[i] isnt curGroup
          curGroup = group[i]
          if (close)
            @context.closePath()
          @context.moveTo(px, py)
          
        @context.lineTo(px, py)

      this
      
    polyline: (x, y, group = null, stroke = null) ->
      @polypath(x, y, group, stroke, null, false)
  
    polygon: (x, y, group = null, stroke = null, fill = null) ->
      @polypath(x, y, group, stroke, fill, true)
      
    segment: (x0, y0, x1, y1, stroke = null) ->
      [x0, y0, x1, y1, stroke] = utils.recycleArrays(x0, y0, x1, y1, stroke)
      if x0.length < 2
        throw "there must be at least two points for a line"

      @context.beginPath()
      for x0i,i in x0
        if stroke?[i] isnt @strokeStyle()
          @context.stroke()
          @context.beginPath()
          @strokeStyle(stroke[i])
        [px0, py0] = @_dataTransform.transformPoint(x0i, y0[i])
        [px1, py1] = @_dataTransform.transformPoint(x1[i], y1[i])
        @context.moveTo(px0, py0)
        @context.lineTo(px1, py1)

      if @strokeStyle() isnt null
        @context.stroke()
            
      this
    
    rect: (left, bottom, right, top, stroke = null, fill = null) ->
      [left, bottom, right, top, stroke, fill] =
        utils.recycleArrays(left, bottom, right, top, stroke, fill)
      if left.length == 0
        return this

      for lefti,i in left
        [pleft, pbottom] = @_dataTransform.transformPoint(lefti, bottom[i])
        [pright, ptop] = @_dataTransform.transformPoint(right[i], top[i])
        if fill isnt null
          @fillStyle(fill[i])
        if @fillStyle() isnt null
          @context.fillRect(pleft, pbottom, pright - pleft, ptop - pbottom)
        if stroke isnt null
          @strokeStyle(stroke[i])
        if @strokeStyle() isnt null
          @context.strokeRect(pleft, pbottom, pright - pleft, ptop - pbottom)

      this

    circle: (x, y, r, stroke = null, fill = null) ->
      [x, y, r, stroke, fill] = utils.recycleArrays(x, y, r, stroke, fill)
      if x.length == 0
        return this

      @context.beginPath()
      for xi,i in x
        newStroke = stroke?[i] isnt @strokeStyle()
        newFill = fill?[i] isnt @fillStyle()
        if newStroke
          @context.stroke()
          @strokeStyle(stroke[i])
        if newFill 
          @context.fill()
          @fillStyle(fill[i])
        if newFill or newStroke
          @context.beginPath()
        [px, py] = @_dataTransform.transformPoint(xi, y[i])
        @context.arc(px, py, r[i], 0, 2 * Math.PI, false)

      if @strokeStyle() isnt null
        @context.stroke()
      if @fillStyle() isnt null
        @context.fill()

      this
      
    text: (text, x, y, fill = null, stroke = null, rotation = 0.0, cex = 1.0,
     hcex = cex, vcex = cex) ->
      [text, x, y, fill, stroke, rotation, hcex, vcex] =
       utils.recycleArrays(text, x, y, fill, stroke, rotation, hcex, vcex)
      if text.length == 0
        return this
      
      for texti,i in text
        [px, py] = @_dataTransform.transformPoint(x[i], y[i])
        @context.resetTransform()
        @context.translate(px, py)
        @context.rotate(rotation[i])
        @context.scale(hcex[i], vcex[i])
        if fill isnt null
          @fillStyle(fill[i])
        if @fillStyle() isnt null
          @context.fillText(texti, 0, 0)
        if stroke isnt null
          @strokeStyle(stroke[i])
        if @strokeStyle() isnt null
          @context.strokeText(texti, 0, 0)

      @context.resetTransform()
      this
     
    image: (image, x, y) ->
      [x, y] = utils.recycleArrays(x, y)
      if x.length == 0
        return this
      for xi,i in x
        [px, py] = @_dataTransform.transformPoint(xi, y[i])
        @context.drawImage(image, px, py) 
      
      this

    ## FIXME: somehow apply the data transform to the path object
    path: (path, stroke = null, fill = null) ->
      [path, stroke, fill] = utils.recycleArrays(path, stroke, fill)
      for xi,i in x
        if fill isnt null
          @fillStyle(fill[i])
        if @fillStyle() isnt null
          @context.fill(path[i])
        if stroke isnt null
          @strokeStyle(stroke[i])
        if @strokeStyle() isnt null
          @context.stroke(path[i])

      this
      
    _rasterizePath: (path) ->
      canvas = document.createElement("canvas")
      pathPainter = new Canvas2DPainter(canvas).lineWidth(@lineWidth())
      cex = @glyphExpansion()
      pathPainter.context.scale(cex, cex)
      pathPainter.path(path, @strokeStyle(), @fillStyle())
      canvas
      
    glyph: (path, x, y, fill = null, stroke = null, cex = 1.0) ->
      [x, y, fill, stroke, cex] = utils.recycleArrays(x, y, fill, stroke, cex)

      for xi,i in x
        newStroke = stroke?[i] isnt @strokeStyle()
        newFill = fill?[i] isnt @fillStyle()
        newCex = cex?[i] isnt @glyphExpansion()
        if newFill
          @strokeStyle(stroke[i])
        if newFill 
          @fillStyle(fill[i])
        if newCex
          @glyphExpansion(cex[i])
        if newFill or newStroke or newCex
          image = @_rasterizePath(path)
        [px, py] = @_dataTransform.transformPoint(xi, y[i])
        @context.drawImage(image, px, py)

      this
        
    _disableImageSmoothing: () ->
      @context.imageSmoothingEnabled = false
      @context.mozImageSmoothingEnabled = false
      @context.webkitImageSmoothingEnabled = false
      @context.oImageSmoothingEnabled = false
