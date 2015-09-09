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
Framer.Device.deviceType = "iphone-6-silver"

dp = (val)->
  return val*2

WIDTH = Framer.Screen.width/2
HEIGHT = Framer.Screen.height/2

background = new BackgroundLayer
  backgroundColor: color.background

_layers = []

class L extends Layer
  constructor: (options)->
    if options.x then options.x = dp options.x
    if options.y then options.y = dp options.y
    if options.width then options.width = dp options.width
    if options.height then options.height = dp options.height
    super options
    _layers.push @

scene = (state)->
  _layers.forEach (layer)->
    hasState = if layer._states and layer._states._orderedStates.indexOf(state) > 0 then true else false
    unless hasState then return
    layer.states.switch state

# make top bar
statusBar = new L
  width: WIDTH
  height: 24
  backgroundColor: color.statusBar
  index: 10000000
  image: './images/statusBar.png'

toolBar = new L
  y: 24
  width: WIDTH
  height: 56
  image: './images/actionBar.png'
  index: 1000

backButton = new L
  x: 12
  y: 12
  width: 32
  height: 32
  backgroundColor: '#000'
  image: './images/back.svg'
  superLayer: toolBar

# tabMenu = new L
#   y: 80
#   width: WIDTH
#   height: 36
#   backgroundColor: color.background
#   index: 999

# class TabButton extends L
#   constructor: (seq, img)->
#     options = 
#       x: seq * Framer.Screen.width/8
#       width: Framer.Screen.width/8
#       height: 36
#       backgroundColor: color.background
#       superLayer: tabMenu
#     super options
#     icon = new L
#       width: 15
#       height: 15
#       superLayer: @
#       image: img
#     icon.center()
#     @on Events.Click, ->
#       tabActivator.states.switch(seq)
#       menuChange seq

# tabs = []
# icons = 
#   '0': './images/0.svg'
#   '1': './images/1.png'
#   '2': './images/2.png'
#   '3': './images/3.png'

# tabs.push new TabButton i, icons[i] for i in [0..3]

# tabActivator = new L
#   x: 32
#   y: 34
#   width: 26
#   height: 2
#   backgroundColor: color.toolBar
#   superLayer: tabMenu
# tabButtonWidth = Framer.Screen.width / 4
# tabButtonMargin = (tabButtonWidth-dp(26))/2
# tabActivator.states.add
#   '0': x: tabButtonMargin
#   '1': x: tabButtonWidth+tabButtonMargin
#   '2': x: tabButtonWidth*2+tabButtonMargin
#   '3': x: tabButtonWidth*3+tabButtonMargin

# activeIcon = new L
#   x: 32
#   y: 90
#   width: 15
#   height: 15
#   image: './images/activeIcon.svg'
#   index: 1000
#   opacity: 0

# status = new L
#   y: 86
#   width: WIDTH
#   height: HEIGHT - 116
#   backgroundColor: 'transperant'
#   index: 100
#   opacity: 0

# wave = new L
#   y: 70
#   width: WIDTH
#   height: 500
#   image: './images/wave2.png'
#   superLayer: status

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
  x: (WIDTH-200)/2
  y: 266
  width: 200
  height: 15
  backgroundColor: 'transperant'
  html: '1.23GB 메모리 확보 가능'
  style:
    'font-size': '1.2em'
    color: color.contentText

number = new L
  x: (WIDTH-220)/2
  y: 150
  width: 200
  height: 100
  html: '75<span style="font-size:0.6em"> %<span>'
  backgroundColor: 'transperant'
  style:
    'font-size': '9em'
    'letter-spacing': '-0.1em'
    'line-height': '0.8em'
    'text-align': 'center'
    'color': color.number

# number2 = new L
#   x: 90
#   y: 180
#   width: 190
#   height: 100
#   backgroundColor: 'transperant'
#   html: '75 <span style="font-size:0.4em">%<span>'
#   index: 99
#   style:
#     'font-size': '9em'
#     'letter-spacing': '-0.1em'
#     'line-height': '0.8em'
#     'color': color.status
#     'text-align': 'center'

executeButton = new L
  x: 120
  y: 303
  width: 120
  height: 40
  borderRadius: 100
  backgroundColor: color.executeButton
  html: '정리하기'
executeButton.style =
  'border': dp(1)+'px solid ' + color.executeButtonBorder
  'text-align': 'center'
  'font-size': '1em'
  'line-height': '2.8em'

list = new L
  x: 0
  y: 398
  width: WIDTH
  height: Screen.height
  backgroundColor: 'transperant'
  index: 900

listLabel = new L
  width: WIDTH
  height: 45
  backgroundColor: color.listLabel
  superLayer: list
  html: '종료할 실행 중인 앱'
  index: 901
  style: 
    'padding': '1em'
    'line-height': '1.2em'

listCounter = new L
  x: WIDTH - 60
  y: -16
  width: 30
  html: '9 개'
  superLayer: listLabel
  backgroundColor: 'transperant'
  style:
    'text-align': 'right'

listWrapper = new L 
  x: 0
  y: 45
  width: WIDTH
  height: Screen.height
  backgroundColor: color.background
  superLayer: list
  index: 910

list.draggable.enabled = true
list.draggable.horizontal = false
list.draggable.speedY = 0.5
list.draggable.constraints =
  x: 0
  y: 180*2
  width: WIDTH
  height: list.height+10000
list.draggable.overdrag = false

class ListItem extends L
  constructor: (seq)->
    super _.assign {}, 
      y: seq * 68
      width: WIDTH
      height: 68
      backgroundColor: color.list
      opacity: 1
      superLayer: listWrapper
    @states.add
      'hide':
        opacity: 0
    checkbox = new L
      x: WIDTH-16-22
      y: 22
      width: 20
      height: 20
      backgroundColor:  color.checkbox
      borderRadius: 2
      superLayer: @
    checkIcon = new L
      x: 1
      y: 1
      width: 18
      height: 18
      image: './images/checkIcon.svg'
      backgroundColor: 'transperant'
      superLayer: checkbox
    content = new L
      x: 14
      y: 12
      height: 44
      width: 100
      image: './images/listItem'+seq%3+'.png'
      superLayer: @
    border = new L
      y: 67
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
    Utils.delay i*0.1, ->
      item.animate
        properties:
          opacity: 0
    Utils.delay i*0.03, ->
      item.animate
        properties:
          x: dp WIDTH-item.width
          # y: item.y-600
          # rotation: -30
        # curve: "cubic-bezier(1,-0.29,.85,.5)"
        # time: 0.4
        curve: 'cubic-bezier(0,.8,1,1)'
        time: 0.4
    Utils.delay 2, ->
      item.x = x
      item.y = y
      item.rotation = rotation
      item.opacity = 1
      listLabel.opacity = 1
      scene 'up'

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
    x: dp 10
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
    x: dp -42
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
# number2.states.add
#   'up':
#     x: dp 10
#     y: dp 68
#     scale: 0.38
#   'down': 
#     x: capture.number.x
#     y: capture.number.y
#     scale: 1

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
  listMoving = [capture.list.y,180*2]
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

list.on Events.DragMove, listDragMoveFunc

listDragEndFunc = (e, obj)->
  direction = if (list.dragStartY - obj.layer.y) > 0 then 'up' else 'down'
  scene direction

list.on Events.DragEnd, listDragEndFunc

fakeCursor = new L
  width: 64
  height: 64
  borderRadius: 100
  backgroundColor: 'rgba(255,255,255,0.3)'
  shadowY: 4
  shadowBlur: 10
  shadowColor: "rgba(0,0,0,0.4)"

fakeCursor.center()
fakeCursor.y += dp 200

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
      y: dp 200
    curve: 'spring(150,30,0)'

  list.animate
    properties:
      y: dp 240
    curve: 'spring(150,30,0)'

  listDragMoveFunc null, { layer: { y: 550 } }

Utils.delay 1, ->
  fakeCursor.states.switch 'out'
  scene 'up'

# menuChange = (seq)->
#   [list, number, contentText, executeButton].forEach (obj)->
#     obj.animate
#       properties:
#         y: Framer.Screen.height
#       curve: 'spring(200,30,0)'
#   Utils.delay 0.2, ->
#     [status].forEach (obj)->
#       obj.animate
#         properties:
#           y: Framer.Screen.height
#         curve: 'spring(100,50,0)'
#   Utils.delay 1.3, ->
#     [number, status, list, executeButton, contentText].forEach (obj)->
#       obj.states.switch 'down'
