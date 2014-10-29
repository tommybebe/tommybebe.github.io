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

listItem = new Layer
  x: 0
  y: 8 * 3
  width: screenWidth
  height: 240
  backgroundColor: 'rgba(255, 255, 255, 1)'
  superLayer: list

listIcon = new Layer
  x: 48
  y: 48
  width: 144
  height: 144
  image:'images/app1.png'
  superLayer: listItem

execution = new Layer
  x: 0
  y: 1200 - (56*3/2)
  width: screenWidth
  height: 56*3
  backgroundColor: 'rgba(255, 5, 255, 0)'
execution.index = index.execution

button = new Layer
  x: screenWidth - (56 * 3) - 48
  y: 0
  width: 56 * 3
  height: 56 * 3
  backgroundColor: 'rgba(231, 76, 60, 1)'
  superLayer: execution
button.borderRadius = button.width

softKey = new Layer
  x: 0
  y: screenHeight - 145
  width: screenWidth
  height: 146
  image: 'images/soft-key.png'
info.index = index.info





















listOriginX = list.x
listOriginY = list.y
list.on Events.DragEnd, (event, layer) ->
  animation = layer.animate
    properties:
      x: listOriginX
      y: listOriginY
    curve: "spring"
    curveOptions:
      friction: 20
      tension: 400
      velocity: 20