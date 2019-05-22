# variables
color = 
  background: 'rgb(13, 22, 35)'
  font: 'rgb(255, 255, 255)'
  easyOptButton: 'rgb(93, 151, 194)'
  weirdAndstupidLine: 'rgb(34, 41, 48)'

Framer.Device.deviceType = "nexus-5-black"
Framer.Defaults.Animation = {
  curve: "spring(500,30,5)"
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

# elements
background = new BackgroundLayer
  backgroundColor: color.background

head = new L
  width: WIDTH
  height: dp 80
  backgroundColor: 'transperant'
  index: 10000000
  image: './images/head.png'

body = new L
  y: dp 80
  width: WIDTH
  height: HEIGHT - dp 80
  backgroundColor: 'transperant'

weirdAndstupidLine1 = new L
  width: dp 1
  height: HEIGHT
  backgroundColor: color.weirdAndstupidLine
  superLayer: body
weirdAndstupidLine1.center()

weirdAndstupidLine2 = new L
  width: WIDTH
  height: dp 1
  backgroundColor: color.weirdAndstupidLine
  superLayer: body
weirdAndstupidLine2.center()

buttonResources = [
  { icon: './images/opt.png', text: '기기최적화' }
  { icon: './images/fileOpt.png', text: '파일최적화' }
  { icon: './images/appMng.png', text: '앱 정리' }
  { icon: './images/appRcvr.png', text: '앱 복원' }
]

class Button extends L
  constructor: (seq)->
    super
      width: WIDTH/2
      height: dp 70
      backgroundColor: 'transperant'
      superLayer: body
    icon = new L
      width: dp 40
      height: dp 40
      backgroundColor: 'transperant'
      image: buttonResources[seq].icon
      superLayer: @
    icon.centerX()
    text = new L
      y: dp 56
      width: @width
      height: dp 30
      backgroundColor: 'transperant'
      html: buttonResources[seq].text
      style:
        'font-size': sp 14
        'line-height': sp 13
        'text-align': 'center'
      superLayer: @
    text.centerX()

buttons = []
buttons.push new Button i for i in [0..3]

buttons[1].x = WIDTH/2
buttons[3].x = WIDTH/2

buttons.map (item)->
  item.y = dp 75

buttons[2].y += dp 338
buttons[3].y += dp 338


easyOpt = new L
  width: dp 212
  height: dp 212
  borderRadius: dp 212
  backgroundColor: 'transperant'
  superLayer: body
easyOpt.center()
easyOpt.force2d = true

progress = new L
  width: dp 212
  height: dp 212
  backgroundColor: 'transperant'
  image: './images/progress.png'
  superLayer: easyOpt
progress.center()

progressWrapper = new L
  width: dp 206
  height: dp 206
  backgroundColor: color.background
  superLayer: easyOpt
  borderRadius: dp 206
progressWrapper.center()

deviceIcon = new L
  y: dp 40
  width: dp 53
  height: dp 77
  backgroundColor: 'transperant'
  image: './images/device.png'
  superLayer: easyOpt
deviceIcon.centerX()

rocketIcon = new L
  y: dp 60
  width: dp 24
  height: dp 30
  backgroundColor: 'transperant'
  image: './images/rocket.png'
  superLayer: easyOpt
rocketIcon.centerX()

easyOptButton = new L
  y: dp((780-509)/2)
  width: dp 112
  height: dp 35
  borderRadius: dp 35
  backgroundColor: color.easyOptButton
  html: '간편최적화'
  style: 
    'text-align': 'center'
    'font-size': sp 14
    'line-height': sp 10
    'padding-top': dp(12)+'px'
  superLayer: easyOpt
easyOptButton.centerX()

easyOptButtonRipple = new L
  y: dp 136
  width: 30
  height: 30
  opacity: 0
  borderRadius: 40
  backgroundColor: color.easyOptButton
  superLayer: easyOpt
easyOptButtonRipple.centerX()

heart = new L
  x: dp 50
  width: WIDTH
  height: WIDTH*1.5
  backgroundColor: 'transperant'
  image: './images/backgroundGradiant.png'
  index: 100

ani = (scale)->
  heart.animate
    properties:
      scale: scale
    curve: 'ease'
    time: 1
big = false

setInterval ->
  Utils.delay 1, ->
    if big 
      ani(1.2)
    else
      ani(0.5)
    big = !big
, 1000


rocketMove = new Animation
  layer: rocketIcon
  properties: 
    scale: 1.1
    y: dp 55
  curve: "ease-in-out"

inwards = rocketMove.reverse()


easyOptExecution = ()->
  r = progress.rotationZ
  animationTime = 4
  easyOptButtonRipple.scale = 1
  easyOptButtonRipple.opacity = 1

  rocketMove.on(Events.AnimationEnd, inwards.start)
  inwards.on(Events.AnimationEnd, rocketMove.start)
  rocketMove.start()
  easyOptButtonRipple.animate
    properties:
      scale: easyOpt.width / 50
      opacity: 0
      curve: 'ease'
      time: 6
  progress.animate
    properties:
      rotationZ: r + 360 * 5
    curve: 'ease-in-out'
    time: animationTime
  Utils.delay animationTime, ()->
    rocketMove.off(Events.AnimationEnd, inwards.start)
    inwards.off(Events.AnimationEnd, rocketMove.start)
    inwards.start()

easyOptButton.on Events.Click, ->
  easyOptExecution()




# example animation
fakeCursor = new L
  width: dp 64
  height: dp 64
  borderRadius: dp 64
  backgroundColor: 'rgba(255,255,255,0.3)'
  shadowY: 4
  shadowBlur: 10
  shadowColor: "rgba(0,0,0,0.4)"

fakeCursor.center()
fakeCursor.y += dp 400

fakeCursor.states.add
  in: 
    scale: 1
    opacity: 1
  out: 
    scale: 2
    opacity: 0
  tab:
    scale: 0.8

Utils.delay 0.5, ->
  fakeCursor.animate
    properties:
      y: dp 380
    curve: 'spring(150,30,0)'

Utils.delay 1.2, ->
  fakeCursor.states.switch 'tab'
Utils.delay 1.4, ->
  easyOptExecution()
  fakeCursor.states.switch 'out'

