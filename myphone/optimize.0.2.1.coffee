color = 
  background: '#0d1623'
  statusBar: '#0e4a93'
  toolBar: '#2864AD'
  status: '#5e97c2'
  list: 'rgb(25, 34, 48)'
  listLabel: 'rgb(72, 81, 93)'
  listBorder: 'rgb(65, 79, 102)'
  checkbox: 'rgba(93,151,194,1)'
  executeButton: 'rgba(93,151,194,1)'
  executeButtonBorder: '0'
  number: '#fff'
  contentText: 'rgb(148, 159, 172)'

Framer.Defaults.Animation = {
  curve: "spring(600,30,5)"
}
Framer.Device.deviceType = "nexus-5-black"

mobile = !!(new MobileDetect(window.navigator.userAgent)).phone() if MobileDetect

dp = (num)->
  return num * (if mobile then 2 else 3)

sp = (num)->
  return (num * (if mobile then 2 else 3)) + 'px'


WIDTH = Framer.Screen.width
HEIGHT = Framer.Screen.height

background = new BackgroundLayer
  backgroundColor: color.background

_layers = []

class L extends Layer
  constructor: (options)->
    super options
    _layers.push @

scene = (state)->
  _layers.forEach (layer)->
    hasState = if layer._states and layer._states._orderedStates.indexOf(state) > 0 then true else false
    unless hasState then return
    layer.states.switch state

# make top bar
head = new L
  width: WIDTH
  height: dp 80
  backgroundColor: 'transperant'
  index: 10000000
  image: './images/head.png'

backButton = new L
  x: dp 12
  y: dp 36
  width: dp 32
  height: dp 32
  backgroundColor: '#000'
  image: './images/back.svg'
  superLayer: head

heart = new L
  width: WIDTH
  height: WIDTH
  backgroundColor: 'transperant'
  image: './images/backgroundGradiant.png'
  index: 100
heart.centerX()

ani = (scale)->
  heart.animate
    properties:
      scale: scale
    curve: 'ease'
    time: 1
t = 1
big = false

setInterval ->
  Utils.delay 1, ->
    if big 
      ani(1.2)
    else
      ani(0.5)
    t++
    big = !big
, 1000

contentText = new L
  y: dp 266
  width: dp 180
  height: dp 15
  backgroundColor: 'transperant'
  html: '1.23GB 메모리 확보 가능'
  style:
    'font-size': sp 16
    'line-height': '1.1em'
    'text-align': 'center'
    color: color.contentText
contentText.centerX()

number = new L
  y: dp 150
  width: dp 180
  height: dp 100
  html: '75<span style="font-size:0.68em"> %<span>'
  backgroundColor: 'transperant'
  style:
    'font-size': sp 110
    'letter-spacing': '-0.1em'
    'line-height': '0.8em'
    'text-align': 'center'
    'color': color.number
number.centerX()

executeButton = new L
  x: dp 120
  y: dp 303
  width: dp 120
  height: dp 40
  borderRadius: dp 100
  backgroundColor: color.executeButton
  html: '정리하기'
executeButton.style =
  'border': dp(1)+'px solid ' + color.executeButtonBorder
  'text-align': 'center'
  'font-size': sp 14
  'line-height': '2.8em'
executeButton.centerX()

list = new L
  x: dp 0
  y: dp 398
  width: WIDTH
  height: Screen.height
  backgroundColor: 'transperant'
  index: 900

listLabel = new L
  width: WIDTH
  height: dp 45
  backgroundColor: color.listLabel
  superLayer: list
  html: '종료할 실행 중인 앱'
  index: 950
  style: 
    'padding': '1em'
    'font-size': sp 14
    'line-height': '1.2em'

listCounter = new L
  x: WIDTH - dp 60
  y: dp -16
  width: dp 30
  html: '9 개'
  superLayer: listLabel
  backgroundColor: 'transperant'
  style:
    'text-align': 'right'

listWrapper = new ScrollComponent
  x: 0
  y: dp 45
  width: WIDTH
  height: HEIGHT - dp(225)
  backgroundColor: color.background
  superLayer: list
  index: 910
listWrapper.scrollHorizontal = false
listWrapper.scrollVertical = false


list.draggable.enabled = true
# list.draggable.enabled = false
list.draggable.horizontal = false
list.draggable.speedY = 0.5
list.draggable.constraints =
  x: 0
  y: dp 180
  width: WIDTH
  height: list.height+10000
list.draggable.overdrag = false

class ListItem extends L
  constructor: (seq)->
    super _.assign {}, 
      y: dp(seq * 68)
      width: WIDTH
      height: dp 68
      backgroundColor: color.list
      opacity: 1
      superLayer: listWrapper.content
    @states.add
      'hide':
        opacity: 0
    checkbox = new L
      x: WIDTH - dp(16+22)
      y: dp 22
      width: dp 20
      height: dp 20
      backgroundColor:  color.checkbox
      borderRadius: 2
      superLayer: @
    checkIcon = new L
      x: dp 1
      y: dp 1
      width: dp 18
      height: dp 18
      image: './images/checkIcon.svg'
      backgroundColor: 'transperant'
      superLayer: checkbox
    content = new L
      x: dp 14
      y: dp 12
      height: dp 44
      width: dp 100
      image: './images/listItem'+seq%3+'.png'
      superLayer: @
    border = new L
      y: dp 67
      width: WIDTH
      height: 1
      backgroundColor: color.listBorder
      superLayer: @

items = []
items.push new ListItem i for i in [0..8]

interval = null
processRun = ()->
  interval = setInterval ()->
    num = Math.floor(Math.random() * 100)
    if num < 10 then num = '0' + num
    number.html = num + ' <span style="font-size:0.4em">%<span>'
  , 50
window.eee = executeButton;
executeButton.on Events.Click, ->
  listLabel.opacity = 0
  processRun()
  scene 'down'
  scene 'execute'
  items.forEach (item, i)->
    {x, y, rotation} = item
    Utils.delay i*0.2, ->
      item.animate
        properties:
          opacity: 0
    Utils.delay i*0.03, ->
      item.animate
        properties:
          x: - item.width
          scale: 0.8
          # y: item.y-600
          # rotation: -30
        # curve: "cubic-bezier(1,-0.29,.85,.5)"
        # time: 0.4
        curve: 'cubic-bezier(0,.8,1,1)'
        time: 0.6
    Utils.delay 2, ->
      item.x = 0
      item.rotation = rotation
      item.opacity = 1
      item.scale = 1
      listLabel.opacity = 1
      scene 'down'

  Utils.delay 1, ->
    number.html = '00 <span style="font-size:0.4em">%<span>'
    clearInterval interval
  Utils.delay 2, ->
    number.html = '75 <span style="font-size:0.4em">%<span>'

capture = 
  # tabMenu: 
  #   x: tabMenu.x
  #   y: tabMenu.y
  # status: 
  #   x: status.x
  #   y: status.y
  # activeIcon: 
  #   x: activeIcon.x
  #   y: activeIcon.y
  contentText: 
    x: contentText.x
    y: contentText.y
  number: 
    x: number.x
    y: number.y
  list: 
    x: list.x
    y: list.y
  executeButton: 
    x: executeButton.x
    y: executeButton.y
  heart:
    x: heart.x
    y: heart.y

# tabMenu.states.add
#   'up':
#     y: capture.tabMenu.y - tabMenu.height
#   'down': 
#     y: capture.tabMenu.y

# status.states.add
#   'up':
#     y: dp -100
#   'down': 
#     y: capture.status.y

# activeIcon.states.add
#   'up':
#     x: dp 18
#     y: dp 96
#     width: dp 40
#     height: dp 40
#     opacity: 1
#   'down': 
#     x: capture.activeIcon.x
#     y: capture.activeIcon.y
#     width: dp 15
#     height: dp 15
#     opacity: 0

contentText.states.add
  'up':
    x: dp 6
    y: dp 150
    scale: 0.85
    opacity: 1
  'down': 
    x: capture.contentText.x
    y: capture.contentText.y
    scale: 1
    opacity: 1
  'execute':
    opacity: 0

number.states.add
  'up':
    x: dp -36
    y: dp 68
    scale: 0.38
  'down': 
    x: capture.number.x
    y: capture.number.y
    scale: 1

heart.states.add
  'up':
    x: dp -100
    y: dp -100
  'down': 
    x: capture.heart.x
    y: capture.heart.y

list.states.add
  'up':
    y: dp 180
  'down': 
    y: capture.list.y

executeButton.states.add
  'up':
    x: Framer.Screen.width - executeButton.width
    y: dp 110
    width: dp 100
    scale: 0.9
    opacity: 1
  'down':
    x: capture.executeButton.x
    y: capture.executeButton.y
    width: dp 120
    scale: 1
    opacity: 1
  'execute':
    scale: 3
    opacity: 0

list.on Events.DragStart, ()->
  list.dragStartY = list.y
listDragMoveFunc = (e, obj)->
  listMoving = [capture.list.y, dp(180)]
  if capture.list.y > obj.layer.y # up
    executeButton.animate
      properties:
        x: Utils.modulate(obj.layer.y, listMoving, [capture.executeButton.x,Framer.Screen.width - executeButton.width], true)
        y: Utils.modulate(obj.layer.y, listMoving, [capture.executeButton.y,dp(110)], true)
        width: Utils.modulate(obj.layer.y, listMoving, [dp(120), dp(100)], true)
        scale: Utils.modulate(obj.layer.y, listMoving, [1, 0.9], true)
      curve: "spring(900,80,0)"
    heart.animate
      properties:
        y: Utils.modulate(obj.layer.y, listMoving, [capture.heart.y,dp(20)], true)
        curve: "spring(900,80,0)"
    contentText.animate
      properties:
        x: Utils.modulate(obj.layer.y, listMoving, [capture.contentText.x,dp(10)], true)
        y: Utils.modulate(obj.layer.y, listMoving, [capture.contentText.y,dp(150)], true)
      curve: "spring(900,80,0)"
    number.animate
      properties:
        y: Utils.modulate(obj.layer.y, listMoving, [capture.number.y,dp(68)], true)
        x: Utils.modulate(obj.layer.y, listMoving, [capture.number.x,dp(-42)], true)
        scale: Utils.modulate(obj.layer.y, listMoving, [1,0.38], true)
        # opacity: Utils.modulate(obj.layer.y, listMoving, [0,1], true)
      curve: "spring(900,80,0)"
    # number2.animate
    #   properties:
    #     y: Utils.modulate(obj.layer.y, listMoving, [capture.number.y,dp(68)], true)
    #     x: Utils.modulate(obj.layer.y, listMoving, [capture.number.x,dp(16)], true)
    #     scale: Utils.modulate(obj.layer.y, listMoving, [1,0.3], true)
    #   curve: "spring(900,80,0)"
  else # down
    console.log 'down'

scrollEndEvent = (e, d, layer)->
  if layer.y > dp 10
    listWrapper.scrollY = 0
    scene 'down'
    listWrapper.scroll = false
    listWrapper.scrollVertical = false
    list.draggable.enabled = true
    list.off Events.DragMove, listDragMoveFunc
    list.off Events.DragEnd, listDragEndFunc
    list.on Events.DragMove, listDragMoveFunc
    list.on Events.DragEnd, listDragEndFunc
    # listWrapper.scrollToPoint(
    #     x: 200, y: dp(0)
    #     true
    #     curve: "ease", time: 0.3
    # )
    # setDragSetting 'down'
    # scene 'down'
    # Utils.delay 1, ->
    #   listWrapper.scroll = false
    #   listWrapper.scrollVertical = false

listWrapper.on Events.ScrollEnd, scrollEndEvent

setListScrollSetting = (toggle)->
  listWrapper.scroll = true
  listWrapper.scrollVertical = true
  listWrapper.scrollHorizontal = false

setDragSetting = (direction)->
  toggle = if direction is 'down' then true else false
  list.draggable.enabled = toggle
  list.off Events.DragMove, listDragMoveFunc
  list.off Events.DragEnd, listDragEndFunc
  list[if toggle then 'on' else 'off'] Events.DragMove, listDragMoveFunc
  list[if toggle then 'on' else 'off'] Events.DragEnd, listDragEndFunc
  setListScrollSetting toggle

listDragEndFunc = (e, obj)->
  movedALot = if ((list.dragStartY - obj.layer.y) > dp(30) or (list.dragStartY - obj.layer.y) < dp(-30)) then true else false
  direction = if obj.layer._states._currentState is 'up' then 'up' else 'down'
  if movedALot
    direction = (if (list.dragStartY - obj.layer.y) > 0 then 'up' else 'down')
    setDragSetting direction if direction is 'up'
  scene direction

list.on Events.DragMove, listDragMoveFunc
list.on Events.DragEnd, listDragEndFunc

# fakeCursor = new L
#   width: dp 64
#   height: dp 64
#   borderRadius: dp 100
#   backgroundColor: 'rgba(255,255,255,0.3)'
#   shadowY: 4
#   shadowBlur: 10
#   shadowColor: "rgba(0,0,0,0.4)"

# fakeCursor.center()
# fakeCursor.y += dp 200

# fakeCursor.states.add
#   in: 
#     scale: 1
#     opacity: 1
#   out: 
#     scale: 2
#     opacity: 0
#   tab:
#     scale: 0.8

# Utils.delay 0.5, ->
#   fakeCursor.animate
#     properties:
#       y: dp 200
#     curve: 'spring(150,30,0)'

#   list.animate
#     properties:
#       y: dp 240
#     curve: 'spring(150,30,0)'

#   listDragMoveFunc null, { layer: { y: 550 } }

# Utils.delay 1, ->
#   fakeCursor.states.switch 'out'
#   scene 'up'
