Framer.Device.deviceType = 'nexus-5-black'

# Variables
screenWidth= 1080
screenHeight= 1920
index =
  execution: 100000
  topBar: 10000
  header: 1000
  info: 100
  list: 1

class Button extends Layer
  constructor: (options)->
    defulatOptions = x:0, y:0, backgroundColor: 'rgba(0, 0, 255, 1)', width: 56*3, height: 56*3
    options = _.assign defulatOptions, options

    super(options)

    options.index && @index = options.index
    
    ripple = new Layer width:options.width, height:options.height, backgroundColor: 'rgba(255, 255, 255, 0.5)'
    ripple.superLayer = @
    ripple.borderRadius = 10000

    ripple.states.add 'on',
      scale: 2
      opacity: 0
    ripple.states.add 'off',
      scale: 0
      opacity: 1
    ripple.states.animationOptions = 
      time: 0.8
      curve: 'ease'
    ripple.states.switchInstant 'off'

    @on Events.Click, (e, layer)->
      ripple.midX = e.offsetX
      ripple.midY = e.offsetY
      ripple.states.switchInstant 'off'
      ripple.states.switch 'on'

bg = new BackgroundLayer
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
  height: 247
  backgroundColor: 'rgba(68, 132, 246, 1)'
header.index = index.header
header.shadowX = 0
header.shadowBlur = 24
header.shadowSpread = 12
header.shadowColor = "rgba(0,0,0,0.2)"

hamburger = new Layer
  x: 48
  y: 48 + 71
  width: 70
  height: 70
  image: 'images/ic_menu_white_48dp.png'
  superLayer: header

pageTitle = new Layer
  x: 72 * 3
  y: 48 + 71
  width: 170
  height: 70
  superLayer: header
  backgroundColor: 'rgba(68, 132, 246, 0)'
pageTitle.html = 'Title'
pageTitle.style["font-size"] = "2em"
pageTitle.style["line-height"] = "1.2em"

info = new Layer
  x: 0
  y: 247
  width: screenWidth
  height: 1920 - 247
  backgroundColor: 'rgba(255, 255, 255, 1)'
info.index = index.info

list = new Layer
  x: 0
  y: 1200
  width: screenWidth
  height: 1920
  backgroundColor: 'rgba(255, 255, 255, 1)'
list.index = index.info
list.shadowY = 0
list.shadowBlur = 12
list.shadowSpread = 0
list.shadowColor = "rgba(0,0,0,0.2)"
list.draggable.enabled = true
list.draggable.speedX = 0
list.draggable.speedY = 0.5

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




# listItem = new Layer
#   x: 0
#   y: 8 * 3
#   width: screenWidth
#   height: 240
#   backgroundColor: 'rgba(255, 255, 255, 1)'

# listItemIcon = new Layer
#   x: 48
#   y: 48
#   width: 36*3
#   height: 36*3
#   image:'images/app1.png'

# listItemTitle = new Layer
#   x: 72*3
#   y: 48
#   width: 272 * 3
#   height: 144
#   backgroundColor: 'rgba(255, 255, 255, 0)'
# listItemTitle.html = '<h3 class="list-item-title">Facebook</h3>'

# listItemSubtitle = new Layer
#   x: 72*3
#   y: 48 + 48
#   width: 272 * 3
#   height: 144
#   backgroundColor: 'rgba(255, 255, 255, 0)'
# listItemSubtitle.html = '<h4 class="list-item-subtitle">Secondary line : have some spaces</h4>'

# listItem.addSubLayer listItemIcon
# listItem.addSubLayer listItemTitle
# listItem.addSubLayer listItemSubtitle
# list.addSubLayer listItem

listItems = []
for i in [0..7]
  item = new ListItem(i)
  item.superLayer = list
  listItems.push item

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
button.borderRadius = 2000
button.shadowY = 2*3
button.shadowBlur = 6*3
button.shadowSpread = 2*3
button.shadowColor = "rgba(0,0,0,0.23)"
button.states.add 'short', y: 1200 - (56*3/2)
button.states.add 'long', y: screenHeight - (56*3) - (16*3) - (48*3)
button.states.animationOptions = 
  time: 0.2
  curve: 'spring'
  curveOptions:
    friction: 20
    tension: 400
    velocity: 20

progress = new Layer
  x: button.x
  y: button.y
  width: 0
  height: 0
  backgroundColor: 'rgba(231, 76, 60, 1)'
  superLayer: execution
progress.borderRadius = 2000

softKey = new Layer
  x: 0
  y: screenHeight - 145
  width: screenWidth
  height: 146
  image: 'images/soft-key.png'
info.index = index.info










# list drag release > expend list layer





# 
button.on Events.Click, (e, layer)->
  animation = progress.animate
    properties:
      x: -1200 + 540
      y: -1200 + 860
      width: 2400
      height: 2400
    time: 0.2


# 
listOriginX = list.x
listOriginY = list.y

list.states.add 'short', y: 1200
list.states.add 'long', y: 500
list.states.animationOptions = 
  time: 0.2
  curve: 'spring'
  curveOptions:
    friction: 20
    tension: 400
    velocity: 20

list.on Events.DragMove, (event, layer) ->
  button.y = layer.y - button.height/2
list.on Events.DragEnd, (e, layer) ->
  # long 
  console.log(e.offsetY)
  if list.y < 1000
    list.states.switch 'long'
    list.draggable.enabled = false
    button.states.switch 'long'
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