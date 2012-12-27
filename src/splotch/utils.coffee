define

  recycleArrays: (args...) ->
    length = a.length for a in args where a instanceof Array
    maxLength = if Math.min.apply(length) == 0 then 0 else Math.max.apply length
    (if a is null then null else recycleArray(a, maxLength)) for a in args
    
  recycleArray: (array, length) ->
    if array not instanceof Array
      array = [ array ]
    if (array.length == length)
      array
    else
      recycled = Array(length)
      for i in [0 .. length - 1]
        recycled[i] = array[i % array.length]
      recycled
