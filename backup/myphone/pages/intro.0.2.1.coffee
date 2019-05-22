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

progressBlank = new L
  width: dp 206
  height: dp 206
  backgroundColor: color.progressBlank
  superLayer: easyOpt
  borderRadius: dp 206
progressBlank.center()

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
  width: dp 23
  height: dp 35
  backgroundColor: 'transperant'
  image: './images/rocket.png'
  superLayer: easyOpt
rocketIcon.centerX()

easyOptButton = new L
  y: dp 135
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

progressNumber = new L
  y: dp 130
  width: dp 130
  height: dp 45
  opacity: 0
  backgroundColor: color.background
  html: '88<span style="font-size:0.4em;">%</span>'
  style: 
    'text-align': 'center'
    'font-size': sp 40
    'line-height': sp 12
  superLayer: easyOpt
progressNumber.centerX()

executionComplete = new L
  width: dp 206
  height: dp 206
  borderRadius: dp 206
  backgroundColor: color.executionComplete
  rotationY: 180
  superLayer: easyOpt
executionComplete.center()

checkIcon = new L
  width: dp 85
  height: dp 62
  backgroundColor: 'transperant'
  superLayer: easyOpt
  rotationY: 180
  opacity: 0
checkIcon.center()

checkIconDraw1 = new L
  x: dp 14
  y: dp 14
  width: dp 16
  height: dp 52
  borderRadius: dp 4
  rotation: -44
  backgroundColor: 'transperant'
  superLayer: checkIcon
checkIconDraw2 = new L
  x: dp 48
  y: dp -4
  width: dp 16
  height: dp 72
  borderRadius: dp 4
  rotation: -135
  backgroundColor: 'transperant'
  superLayer: checkIcon

checkIconDrawMover1 = new L
  width: dp 16
  height: dp 16
  borderRadius: dp 4
  backgroundColor: '#fff'
  rotationY: 180
  superLayer: checkIconDraw1

checkIconDrawMover2 = new L
  width: dp 16
  height: dp 16
  borderRadius: dp 4
  opacity: 0
  rotationY: 180
  backgroundColor: '#fff'
  superLayer: checkIconDraw2

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

progressEl = [progressWrapper, deviceIcon, rocketIcon, progressNumber, easyOptButton, executionComplete, checkIcon, checkIconDrawMover1, checkIconDrawMover2]

commonState 'spin', { rotationY: 180 }, progressEl
commonState 'spinBack', { rotationY: 0 }, progressEl

checkAniReady = ()->
  checkIcon.opacity = 1
  checkIconDrawMover1.height = dp 16
  checkIconDrawMover2.height = dp 16
  checkIconDrawMover1.y = 0
  checkIconDrawMover2.y = 0
  checkIconDrawMover2.opacity = 0

checkAni = ()->
  checkAniReady()
  checkIconDrawMover1.animate
    properties:
      height: dp 70
    curve: 'ease-out'
    time: 0.1
  Utils.delay 0.05, ->
    checkIconDrawMover2.opacity = 1
    checkIconDrawMover2.animate
      properties:
        height: dp 72
      curve: 'ease-in'
      time: 0.1
  Utils.delay 1.3, ->
    checkIconDrawMover1.animate
      properties:
        y: dp 80
    Utils.delay 0.1, ->
      checkIconDrawMover2.opacity = 1
      checkIconDrawMover2.animate
        properties:
          y: dp 80

interval = null
processRun = ()->
  interval = setInterval ()->
    num = Math.floor(Math.random() * 100)
    if num < 10 then num = '0' + num
    progressNumber.html = num + '<span style="font-size:0.4em;">%</span>'
  , 30

progressNumberStart = ()->
  Utils.delay 0.3, ->
    processRun()
  progressNumber.animate
    properties:
      opacity: 1

progressNumberStop = ()->
  clearInterval interval
  progressNumber.animate
    properties:
      opacity: 0
          
rocketMove = new Animation
  layer: rocketIcon
  properties: 
    scale: 1.1
    y: dp 55
  curve: "ease-in-out"
inwards = rocketMove.reverse()

rocketMoreMove = new Animation
  layer: rocketIcon
  properties: 
    scale: 1.3
    y: dp 50
  curve: "ease-in-out"
backMove = rocketMoreMove.reverse()

rocketFire = ()->
  fired = './images/firedRocket.png'
  normal = './images/rocket.png'
  toggle = false
  rocketIcon.image = fired
  fire = setInterval ()->
    if toggle
      rocketIcon.image = fired
    else 
      rocketIcon.image = normal
    toggle = !toggle
  , 900

  Utils.delay 4, ->
    rocketIcon.image = normal
    clearInterval fire


normalRocketMove = ()->
  rocketMoreMove.off(Events.AnimationEnd, backMove.start)
  inwards.off(Events.AnimationEnd, rocketMoreMove.start)
  rocketMove.on(Events.AnimationEnd, inwards.start)
  inwards.on(Events.AnimationEnd, rocketMove.start)
  rocketMove.start()

executionRocketMove = ()->
  rocketMove.off(Events.AnimationEnd, inwards.start)
  inwards.off(Events.AnimationEnd, rocketMove.start)
  rocketMoreMove.on(Events.AnimationEnd, backMove.start)
  backMove.on(Events.AnimationEnd, rocketMoreMove.start)
  rocketMoreMove.start()

normalRocketMove()

easyOptExecution = ()->
  r = progress.rotationZ
  animationTime = 4

  executionRocketMove()
  progressNumberStart()
  rocketFire()

  progressMove.off(Events.AnimationEnd, progressMove.start)

  progress.animate
    properties:
      rotationZ: r + 360 * 10
    curve: 'ease-in-out'
    time: animationTime

  Utils.delay animationTime, ->
    scene 'spin'
    progressNumberStop()
    Utils.delay 0.5, ->
      checkAni()
      Utils.delay 1.5, ->
        scene 'spinBack'
        normalRocketMove()
        progressMove.on(Events.AnimationEnd, roll)
        roll()

easyOptButton.on Events.Click, ->
  easyOptExecution()


progressMove = new Animation
  layer: progress
  properties: 
    rotationZ: progress.rotationZ + 360
  curve: "linear"
  time: 30

roll = ->
  progress.rotationZ = 0
  progressMove.start()

progressMove.on(Events.AnimationEnd, roll)
progressMove.start()


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
Utils.delay 1.5, ->
  easyOptExecution()
  fakeCursor.states.switch 'out'

