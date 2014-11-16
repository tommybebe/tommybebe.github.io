Framer.Device.deviceType = 'nexus-5-black'

# Variables
screenWidth= 1080
screenHeight= 1920
fullScreen = x:0, y:0, width:screenWidth, height:screenHeight
index =
  execution: 100000
  topBar: 10000
  header: 1000
  list: 100
  info: 1

# colors
color = 
  red: 'rgba(231, 76, 60, 1)'

# animation options
aniOpt =
  paper: 
    time: 0.3
    curve: 'ease-out'
  slow:
    time: 0.5
    curve: 'ease-out'
  spring:
    time: 40
    curve: 'spring'
    curveOptions:
      friction: 30
      tension: 300
      velocity: 20
  ripple:
    time: 0.2
    curve: 'cubic-bezier(.05,.5,.5,.95)'

spring = 
  time: 0.9
  curve: 'spring'
  curveOptions:
    friction: 20
    tension: 200
    velocity: 10
lightSpring = 
  time: 0.5
  curve: 'spring'
  curveOptions:
    friction: 20
    tension: 400
    velocity: 20



id = ->
  '_' + Math.random().toString(36).substr(2, 9)

class Scene
  constructor: ()->
    @stateName = id()
    @states = []
    @defaultAniOpt = aniOpt.paper
      # time: 0.3
      # curve: 'cubic-bezier(0,1,.35,.9)'
      # curveOptions:
      #   friction: 20
      #   tension: 400
      #   velocity: 20
  add: (layer, options, animation)->
    layer.states.add @stateName, options
    @states.push
      layer: layer
      animation: animation
  run: (instant)->
    @states.forEach (item)=>
      _animation = item.layer.states.animationOptions
      item.layer.states.animationOptions = item.animation || if _.isEmpty _animation then @defaultAniOpt else _animation
      if instant
        item.layer.states.switchInstant @stateName
      else
        item.layer.states.switch @stateName
      item.layer.states.animationOptions = _animation
    
    after = (cb)=>
      _cb = (e, layer)=>
        @states[0].layer.off Events.AnimationStop, _cb
        cb()
      @states[0].layer.on Events.AnimationStop, _cb

    return { after: after }
    
class Button extends Layer
  constructor: (options)->
    defulatOptions = x:0, y:0, backgroundColor: 'rgba(0, 0, 255, 1)', width: 56*3, height: 56*3
    options = _.assign defulatOptions, options

    super(options)

    options.index && @index = options.index
    
    # ripple event sequence.
    # 1. 터치 시작과 함께 터치된 곳에서 0x0 크기 + 0% 투명도를 + parent의 1.5배 scale ripple 이 하나 생겨난다.
    # 2. 터치 release 하기 전까지 애니메이션을 진행하며, 
    # 3. 터치 좌표가 변경될 경우 좌료를 따라 움직인다.
    # 4. 터치 release 되면 ripple을 커지기 전의 상태로 돌린다.
    # 5. 단, 완전히 ripple이 커지기 전에 release 이벤트가 일어나면, 커지는 애니메이션을 기다린 후 뒤의 애니메이션을 진행한다.
    ripple = new Layer width:options.width, height:options.height, backgroundColor: 'rgba(255, 255, 255, 0.3)'
    ripple.superLayer = @
    ripple.borderRadius = '50%'
    ripple.states.add 'focus', scale: 1.8, opacity: 1
    ripple.states.add 'blur', scale: 2, opacity: 0
    ripple.states.add 'off', scale: 0, opacity: 0
    ripple.states.animationOptions = aniOpt.ripple
    ripple.states.switchInstant 'off'

    focusEnd = (e, layer)->
      ripple.focusEnd = true
    blurStart = (e, layer)->
      ripple.focusEnd = false
      ripple.states.switch 'blur'

    @on Events.TouchStart, (e, layer)->
      ripple.states.switchInstant 'off'
      ripple.midX = e.offsetX
      ripple.midY = e.offsetY
      ripple.states.switch 'focus'
      ripple.once Events.AnimationEnd, focusEnd

    @on Events.TouchEnd, (e, layer)->
      # 애니메이션 끝나고, 홀드된 상태
      if ripple.focusEnd
        ripple.states.switch 'blur'
      # 애니메이션 끝내기 전에 손을 뗀 경우 기다린 다음 애니메이션 진행
      else
        ripple.once Events.AnimationEnd, blurStart
      ripple.focusEnd = false


    @on Events.DragMove, (e, layer)->
      ripple.midX = e.offsetX
      ripple.midY = e.offsetY


bg = new BackgroundLayer
  x:0
  y:0
  width: screenWidth
  height: screenHeight
  backgroundColor: '#555'

topBar = new Layer
  x: 0
  y: 0
  width: screenWidth
  height: 71
  image:'images/top-bar.png'
topBar.index = index.topBar

header = new Layer
  x: 0
  y: 0
  width: screenWidth
  height: 247+15
header.style['background'] = '-webkit-linear-gradient(right, rgba(168, 132, 146, 0.97) 0%, rgba(68, 132, 246, 0.97) 100%)'
header.index = index.header
header.shadowX = 0
header.shadowBlur = 24
header.shadowSpread = 12
header.shadowColor = "rgba(0,0,0,0.2)"

hamburger = new Button
  x: 48
  y: 48 + 71
  width: 36*3
  height: 36*3
  backgroundColor: 'rgba(255, 255, 255, 0)'
  superLayer: header
hamburger.borderRadius = '50%'
hamburger.on Events.Click, (e, layer)->


hamburgerIcon = new Layer
  width: 70
  height: 70
  midX: hamburger.width/2
  midY: hamburger.height/2
  image: 'images/ic_menu_white_48dp.png'
  superLayer: hamburger

menu = new Layer
  x: -screenWidth, y: 247
  width: screenWidth - (56*3)
  height: screenHeight + header.y + header.height
  backgroundColor: 'rgba(255, 255, 255, 1)'

menuShadow = new Layer
  y: 247, width: screenWidth, height: screenHeight, opacity:0
  backgroundColor: 'rgba(0,0,0,0.7)'

menu.index = 0
menuShadow.index = 0

menuOpen = new Scene()
menuOpen.add menu, x:0
menuOpen.add menuShadow, opacity:1
menuClose = new Scene()
menuClose.add menu, x:-screenWidth
menuClose.add menuShadow, opacity:0

# toggle side menu
hamburger.on Events.Click, (e, layer)->
  if !hamburger.status
    hamburger.status = true
    menuOpen.run()
    menu.index = index.execution + 2
    menuShadow.index = index.execution + 1
  else 
    hamburger.status = false
    menuClose.run().after ->
      menu.index = 0
      menuShadow.index = 0
# shadow can close menu too
menuShadow.on Events.Click, (e, layer)->
  hamburger.status = false
  menuClose.run().after ->
      menu.index = index.execution + 2
      menuShadow.index = index.execution + 1

pageTitle = new Layer
  x: 72 * 3
  y: 48 + 71 + 15
  width: 170
  height: 70
  superLayer: header
  backgroundColor: 'rgba(68, 132, 246, 0)'
pageTitle.html = 'Title'
pageTitle.style["font-size"] = "2em"
pageTitle.style["line-height"] = "1.2em"

info = new Layer
  x: 0
  y: 0
  width: screenWidth
  height: screenHeight
  backgroundColor: 'rgba(255, 255, 255, 1)'
info.index = index.info

indicator = new Layer
  x:-40, y:-20, width: 0, height: screenHeight+20, superLayer: info
indicator.skew = 3

infoText = new Layer
  x:0, y:400, width:screenWidth, height:screenHeight
  superLayer: info, backgroundColor: 'transparent'
infoText.html = '<h1 class="info-text">00%</h1>'

list = new Layer
  width: screenWidth
  height: 1920
  backgroundColor: 'rgba(255, 255, 255, 1)'
list.index = index.list
list.shadowY = 0
list.shadowBlur = 12
list.shadowSpread = 0
list.shadowColor = "rgba(0,0,0,0.2)"
list.draggable.enabled = true
list.draggable.speedX = 0
list.draggable.speedY = 0.5

listInner = new Layer
  width: screenWidth
  height: list.height
  backgroundColor: 'rgba(255, 255, 255, 1)'
  superLayer: list
listInner.index = list.index + 1
listInner.draggable.enabled = false
listInner.draggable.speedX = 0
listInner.states.add 'defalut', y:0, 
listInner.states.animationOptions = aniOpt.spring

class ListItem extends Layer
  constructor: (index, type)->

    app = ['instagram', 'Foto', 'Telegram', 'Messanger', 'Facebook', 'Monotor', 'Battery Manager', 'Tumblr']

    super
      x: 0, y: 8*3 + (index*72*3), width: screenWidth, height: 72*3, backgroundColor: 'rgba(255, 255, 255, 1)'

    icon = new Layer
      x: 16*3, y: 16*3, width: 36*3, height: 36*3
      image:'images/app'+index+'.png'
      superLayer: @

    title = new Layer
      x: 72*3
      y: 48
      width: 272 * 3
      height: 144
      backgroundColor: 'rgba(255, 255, 255, 0)'
      superLayer: @
    title.html = '<h3 class="list-item-title">'+app[i]+'</h3>'

    subtitle = new Layer
      x: 72*3
      y: 16*3 + 20*3
      width: 272 * 3
      height: 144
      backgroundColor: 'rgba(255, 255, 255, 0)'
      superLayer: @
    subtitle.html = '<h4 class="list-item-subtitle">Secondary line : have some spaces</h4>'

    action = new Layer
      x: (360-16)*3
      y: 16*3 + 20*3
      width: 272 * 3
      height: 144
      backgroundColor: 'rgba(255, 255, 255, 0)'
      superLayer: @
    action.html = '<input type="checkbox"/>'


listItems = []
for i in [0..7]
  item = new ListItem(i)
  item.superLayer = listInner
  listItems.push item

# states - long or short
list.states.add 'short', y: 1200
list.states.add 'long', y: 500
list.states.animationOptions = aniOpt.spring
list.on Events.DragStart, (e, layer) ->
  button.y = layer.y - button.height/2
list.on Events.DragMove, (e, layer) ->
  button.y = layer.y - button.height/2

setListInnerPosition = (e, layer)->
  if layer.y > 0
    layer.states.switch 'defalut'
  if layer.y > 400
    console.log(1)
    list.states.switch 'short'
    
    list.animate
      properties:
        y:1000
    button.states.switch 'short'
    list.draggable.enabled = true
    listInner.draggable.enabled = false
    list.on Events.DragEnd, setListPosition
    listInner.off Events.DragEnd, setListInnerPosition

setListInnerPositionToLong = (e, layer)->
    if layer.y > 400
      layer.y = 0
      list.states.switch 'short'
      list.on Events.DragEnd, setListPosition
      button.states.switch 'short'
      list.draggable.enabled = true
      listInner.draggable.enabled = false

setListPosition = (e, layer) ->
  # long 
  if list.y < 1000
    list.states.switch 'long'
    list.draggable.enabled = false
    listInner.draggable.enabled = true
    # listInner.scrollVertical = true
    button.states.switch 'long'
    layer.off Events.DragEnd, setListPosition
    # listInner.on Events.DragEnd, setListInnerPosition
    listInner.on Events.DragMove, setListInnerPositionToLong
  else 
    list.states.switch 'short'
    button.states.switch 'short'

list.on Events.DragEnd, setListPosition



execution = new Layer
  x: 0
  y: 0
  width: screenWidth
  height: screenHeight
  backgroundColor: 'rgba(255, 5, 255, 0)'
execution.index = index.execution

button = new Button
  x: screenWidth - (56 * 3) - 48
  y: 1200 - (56*3/2)
  width: 56 * 3
  height: 56 * 3
  backgroundColor: 'rgba(231, 76, 60, 1)'
  superLayer: execution
button.borderRadius = '50%'
button.shadowY = 2*3
button.shadowBlur = 6*3
button.shadowSpread = 2*3
button.shadowColor = "rgba(0,0,0,0.23)"
button.states.add 'short', y: 1200 - (56*3/2)
button.states.add 'long', y: 500 - (56*3/2)
button.states.animationOptions = 
  time: 0.2
  curve: 'spring'
  curveOptions:
    friction: 20
    tension: 400
    velocity: 20

progress = new Layer
  width:0, height:0
  backgroundColor: color.red
  superLayer: execution
progress.borderRadius = '50%'

# softKey = new Layer
#   x: 0
#   y: screenHeight - 145
#   width: screenWidth
#   height: 146
#   image: 'images/soft-key.png'
# info.index = index.info

home = new Layer
  image: 'images/home.jpg'
home.index = 1
splashScreen = new Layer
  image: 'images/splash-screen.png'
splashScreen.index = 1

blank = new Scene()
blank.add topBar, opacity:0
blank.add header, x:0, y:-header.height-50
blank.add list, x:0, y:screenHeight
blank.add button, scale:0
blank.run true

beforeStart = new Scene()
beforeStart.add home, fullScreen
beforeStart.add splashScreen, x:800, y:1200, opacity:0
beforeStart.run true

startApp = new Scene()
startApp.add splashScreen, _.assign(fullScreen, {opacity:1})
startApp.add topBar, opacity:1
startApp.add home, opacity:0

load = new Scene()
load.add indicator, { width: screenWidth*0.65 }
load.add splashScreen, { opacity:0 }, aniOpt.slow

loadComplete = new Scene()
loadComplete.add header, x:0, y:-15
loadComplete.add list, x:0, y:1200
loadComplete.add button, { scale:1 }, spring

# home.on Events.Click, (e, layer)->
startApp.run().after ->
  load.run().after ->
    loadComplete.run().after ->

button.on Events.Click, (e, layer)->
  progress.width = 1000
  progress.height = 1000
  progress.scale = 0.1
  progress.midX = button.midX
  progress.midY = button.midY
  animation = progress.animate
    properties:
      scale: 5
    time: 1
    curve: aniOpt.ripple.curve

# # 
# listOriginX = list.x
# listOriginY = list.y

# list.states.add 'short', y: 1200
# list.states.add 'long', y: 500
# list.states.animationOptions = 
#   time: 0.2
#   curve: 'spring'
#   curveOptions:
#     friction: 20
#     tension: 400
#     velocity: 20

# list.on Events.DragMove, (event, layer) ->
#   button.y = layer.y - button.height/2
# list.on Events.DragEnd, (e, layer) ->
#   # long 
#   console.log(e.offsetY)
#   if list.y < 1000
#     list.states.switch 'long'
#     list.draggable.enabled = false
#     button.states.switch 'long'
  # animation = layer.animate
  #   properties:
  #     x: listOriginX
  #     y: listOriginY
  #   curve: "spring"
  #   curveOptions:
  #     friction: 20
  #     tension: 400
  #     velocity: 20
  # animation2 = button.animate
  #   properties:
  #     y: listOriginY - button.height/2
  #   curve: "spring"
  #   curveOptions:
  #     friction: 20
  #     tension: 400
  #     velocity: 20

