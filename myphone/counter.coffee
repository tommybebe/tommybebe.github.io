# variables
color = 
  background: 'rgb(13, 22, 35)'
  progressBlank: 'rgb(10, 10, 10)'
  font: 'rgb(255, 255, 255)'
  easyOptButton: 'rgb(93, 151, 194)'
  weirdAndstupidLine: 'rgb(34, 41, 48)'
  pannel: '#283955'
  executionComplete: 'rgb(40, 57, 85)'

Framer.Device.deviceType = "nexus-5-black"
Framer.Defaults.Animation = {
  curve: "spring(150,15,0)"
}

WIDTH = Framer.Screen.width
HEIGHT = Framer.Screen.height

# tools
mobile = !!(new MobileDetect(window.navigator.userAgent)).phone() if MobileDetect

dp = (num)->
  return num * (if mobile then 2 else 3)

sp = (num)->
  return (num / (if mobile then 15 else 10)) + 'em'

_layers = []

class L extends Layer
  constructor: (options)->
    super options
    _layers.push @

scene = (state, option)->
  _layers.forEach (layer)->
    layer.states.switch(state, option) if layer._states and layer._states._orderedStates.indexOf(state) > 0 

commonState = (name, state, layers)->
  layers.forEach (layer)->
    defaultAttrs = {}
    Object.keys(state).forEach (attr)->
      defaultAttrs[attr] = layer[attr] + state[attr]
    layer.states.add name, defaultAttrs

# elements
background = new BackgroundLayer
  backgroundColor: color.background


class Counter extends L
  constructor: (options, font = {})->
    defaultAttrs = 
      x: 0
    super _.assign defaultAttrs, options
    @time = options.time
    num1 = new L
      width: @width
      height: @height
      backgroundColor: 'transperant'
    num2 = num1.copy()
    num3 = num1.copy()

    @numbers = [num1, num2, num3]
    @numberStack = [num1, num2, num3]
    @numbers.forEach (num, i)=>
      num.y = i * @height - @height
      num.html = i
      num.superLayer = @
      num.style =
        'font-size': sp(@height/3)
        'line-height': '1.1em'

  set: ()=>
    @numbers.unshift(@numbers.pop())
    n = parseInt @numbers[1].html
    @numbers[0].html = parseInt(@numbers[1].html) - (if n is 0 then -9 else 1)
    @numbers[0].y = -@height

  move: ()=>
    @numbers.forEach (num, i)=>
      numMoveAnimation = new Animation
        layer: num
        properties:
          y: num.y + @height
        curve: 'ease-in'
        time: @time/2
      numMoveAnimation.start()
      numMoveAnimation.on(Events.AnimationEnd, @set) if i is 2


t = 0.2
counter = new Counter
  time: t
  y: dp 150
  width: dp 150
  height: dp 150

Utils.delay t*1, ->
  counter.move()
Utils.delay t*2, ->
  counter.move()
Utils.delay t*3, ->
  counter.move()
Utils.delay t*4, ->
  counter.move()
Utils.delay t*5, ->
  counter.move()