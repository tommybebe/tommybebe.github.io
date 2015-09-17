Framer.Defaults.Animation = {
  curve: "spring(600,30,5)"
}
Framer.Device.deviceType = "nexus-5-black"

mobile = !!(new MobileDetect(window.navigator.userAgent)).phone() if MobileDetect

dp = (num)->
  return num * (if mobile then 2 else 3)

sp = (num)->
  return (num * (if mobile then 2 else 3)) + 'px'


# VARIABLES!
WIDTH = Framer.Screen.width
HEIGHT = Framer.Screen.height

color = 
  background: '#0d1623'
  head: '#252e3e'
  magnifierIcon: 'rgba(25, 46, 77, 0.8)'
  statusBar: '#0e4a93'
  toolBar: '#2864AD'
  status: '#5e97c2'
  list: 'rgb(25, 34, 49)'
  listLabel: 'rgb(72, 81, 93)'
  listBorder: 'rgb(65, 79, 102)'
  subList: 'rgb(18, 24, 36)'
  checkbox: 'rgba(93,151,194,1)'
  executeButton: '#5d97c2'
  executeButtonBorder: '0'
  number: '#fff'
  contentText: 'rgb(148, 159, 172)'
  completeMessage: '#949fac'
  moreContentsLabel: '#48515d'
  moreItem: '#252f3d'

smallFontStyle = 
  'font-size': sp 10
  'line-height': '1em'
  'color': 'rgba(255, 255, 255, 0.7)'

listTitleFontStyle = 
  'font-size': sp 13
  'line-height': '1em'
  'color': '#fff'

normalFontStyle = 
  'font-size': sp 20
  'line-height': '1em'
  'text-align': 'center'
  'color': '#fff'

style = 
  headTitle:
    'font-size': sp 19
    'line-height': '1em'
    'color': '#fff'
    'font-weight': '500'
  listLabel:
    'padding': sp 15
    'font-size': sp 13
    'line-height': '1em'
  listItemTitle:
    'font-size': sp 13
    'line-height': '1em'
    'color': '#fff'
    'font-weight': '400'
  listItemInfo: 
    'font-size': sp 10
    'line-height': '1em'
    'color': 'rgba(255,255,255,0.5)'
    'font-weight': '400'
  searchText:
    'font-size': sp 16
    'line-height': '1em'
    'text-align': 'center'
    color: color.contentText
  bigNumber:
    'font-size': sp 110
    'letter-spacing': '-0.1em'
    'line-height': '0.9em'
    'text-align': 'center'
    'color': color.number

background = new BackgroundLayer
  backgroundColor: color.background

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


# make top bar
head = new L
  width: WIDTH
  height: dp 80
  backgroundColor: 'transperant'
  index: 10000000
  image: './images/head.png'

backButton = new L
  x: dp 16
  y: dp 45
  width: dp 20
  height: dp 16
  image: './images/back.png'
  superLayer: head

headTitle = new L
  x: dp 55
  y: dp 44
  width: dp 200
  height: dp 20
  html: '기기최적화'
  backgroundColor: color.head
  style: style.headTitle

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

search = new L
  y: dp 157
  width: WIDTH
  height: dp 110
  scale: 1
  opacity: 0
  backgroundColor: 'transperant'

searchIcon = new L
  width: dp 88
  height: dp 108
  superLayer: search
  image: './images/fileOpt-loading-icon.png'
searchIcon.centerX()

magnifierIcon = new L
  x: searchIcon.x + dp(60)
  y: dp 34
  width: dp 57
  height: dp 57
  superLayer: search
  backgroundColor: 'transperant'
magnifierGlass = new L
  width: dp 47
  height: dp 47
  superLayer: magnifierIcon
  backgroundColor: color.magnifierIcon
  borderRadius: dp 47
  style:
    border: dp(5)+'px solid #fff'
magnifierHandle = new L
  x: dp 45
  y: dp 35
  width: dp 5
  height: dp 25
  borderRadius: dp 5
  rotation: -47
  superLayer: magnifierIcon
  backgroundColor: '#fff'

magnifierIconMovePoint = [
  { x: magnifierIcon.x-dp(30), y: magnifierIcon.y-dp(20) }
  { x: magnifierIcon.x-dp(40), y: magnifierIcon.y+dp(15) }
  { x: magnifierIcon.x, y: magnifierIcon.y }
]
magnifierIconAnimations = magnifierIconMovePoint.map (point)->
  return new Animation
    layer: magnifierIcon
    properties: point

magnifierIconAnimationNumber = 0
magnifierIconAnimations[magnifierIconAnimationNumber].start()
magnifierIcon.on Events.AnimationStop, ()->
  magnifierIconAnimationNumber += 1
  if magnifierIconAnimationNumber is 3
    magnifierIconAnimationNumber = 0
  magnifierIconAnimations[magnifierIconAnimationNumber].start()

searchText = new L
  y: dp 292
  width: WIDTH
  height: dp 16
  backgroundColor: 'transperant'
  html: '정리가 필요한 파일을 찾고 있습니다.'
  scale: 1
  opacity: 0
  style: style.searchText
searchText.centerX()

number = new L
  y: dp 150
  width: dp 280
  height: dp 100
  opacity: 0
  scale: 0
  html: '17<span style="font-size:0.68em"> %<span>'
  backgroundColor: 'transperant'
  style: style.bigNumber
number.centerX()

contentText = new L
  x: (WIDTH - dp(190))/2
  y: dp 252
  width: dp 190
  height: dp 16
  opacity: 0
  scale: 0
  backgroundColor: 'transperant'
  html: '저장공간 12GB / 27.33GB'
  style: style.searchText

executeButton = new L
  x: dp 120
  y: dp 290
  width: dp 120
  height: dp 40
  borderRadius: dp 100
  opacity: 0
  scale: 0
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
  y: dp 381
  width: WIDTH
  height: Screen.height
  backgroundColor: 'transperant'
  index: 900

listLabel = new L
  width: WIDTH
  height: dp 42
  backgroundColor: color.listLabel
  superLayer: list
  html: '정리할 파일'
  index: 950
  style: style.listLabel

listWrapper = new ScrollComponent
  x: 0
  y: dp 43
  width: WIDTH
  height: HEIGHT - dp(225)
  backgroundColor: color.background
  superLayer: list
  index: 910
listWrapper.scrollHorizontal = false
listWrapper.scrollVertical = false

list.draggable.enabled = false
list.draggable.horizontal = false
list.draggable.speedY = 0.5
list.draggable.constraints =
  x: 0
  y: dp 180
  width: WIDTH
  height: list.height+10000
list.draggable.overdrag = false

class ListItem extends L
  constructor: (seq, item)->
    @infoText = item.info
    @toggle = true
    super _.assign {}, 
      y: dp(seq * 62)
      width: WIDTH
      height: dp 62
      backgroundColor: color.list
      opacity: 1
      superLayer: listWrapper.content
    @states.add
      'hide':
        opacity: 0
    @checkbox = new L
      x: WIDTH - dp(16+22)
      y: dp 21
      width: dp 20
      height: dp 20
      backgroundColor: 'transperant'
      borderRadius: 2
      superLayer: @
      style:
        'border': dp(1)+'px solid rgb(73, 83, 95)'
    @checkIcon = new L
      x: dp 1
      y: dp 1
      width: dp 18
      height: dp 18
      scale: 0
      image: './images/checkIcon.svg'
      backgroundColor: 'transperant'
      superLayer: @checkbox
    title = new L
      x: dp 15
      y: dp 14
      height: dp 13
      width: dp 200
      superLayer: @
      html: item.title
      style: style.listItemTitle
      backgroundColor: 'transperant'
    @info = new L
      x: dp 15
      y: dp 34
      height: dp 13
      width: dp 200
      superLayer: @
      html: '계산중..'
      backgroundColor: 'transperant'
      style: style.listItemInfo
    border = new L
      y: dp 60
      width: WIDTH
      height: 1
      backgroundColor: color.listBorder
      superLayer: @
  textToggle: ()=>
    if @toggle
      @info.html = @infoText
      @checkbox.backgroundColor = color.checkbox
      @checkbox.style['border'] = 0
      @checkIcon.animate
        properties:
          scale: 1
    else
      @info.html = '계산중..'
      @checkbox.backgroundColor = 'transperant'
      @checkbox.style['border'] = dp(1)+'px solid rgb(73, 83, 95)'
      @checkIcon.animate
        properties:
          scale: 0
    @toggle = !@toggle

listItems = []
itemInfos = [
  { title: '불필요한 파일', info: '128개 / 1.82GB' }
  { title: '앱 제거후 잔여 파일', info: '54개 / 95MB' }
  { title: 'APK 파일', info: '37개 / 738MB' }
  { title: '대용량 파일', info: '12개 / 4.5GB' }
]
itemInfos.forEach (item, i)->
  listItems.push new ListItem i, item

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

interval = null
processRun = ()->
  interval = setInterval ()->
    num = Math.floor(Math.random() * 100)
    if num < 10 then num = '0' + num
    number.html = num + ' <span style="font-size:0.4em">%<span>'
  , 50

completeMessage = new L
  y: dp 240
  width: WIDTH
  height: dp 40
  opacity: 0
  backgroundColor: 'transperant'
  html: '파일 최적화가 완료되어<br/>1.23GB의 저장 공간을 확보했습니다.'
  style: 
    'text-align': 'center'
    'font-size': sp 16
    'line-height': '1.2em'
    'color': color.completeMessage

moreContents = new L
  y: HEIGHT
  width: WIDTH
  height: dp(42) + dp(8)*2 + dp(60)*2 + dp(4)
  backgroundColor: 'transperant'

moreContentsLabel = new L
  width: WIDTH
  height: dp 42
  backgroundColor: color.moreContentsLabel
  html: '더 많은 항목을 최적화 할 수 있습니다.'
  superLayer: moreContents
  style: 
    'font-size': sp 13
    'line-height': '1em'
    'padding': dp(15) + 'px'

moreItem1 = new L
  x: dp 8
  y: dp 50
  width: WIDTH - dp(16)
  height: dp 60
  backgroundColor: color.moreItem
  superLayer: moreContents

moreItemIcon = new L
  x: dp 17
  y: dp 17
  width: dp 26
  height: dp 26
  image: './images/1.png'
  backgroundColor: 'transperant'
  superLayer: moreItem1

moreItemTitle = new L
  x: dp 62
  y: dp 17
  width: dp 200
  height: dp 13
  html: '기기 최적화'
  superLayer: moreItem1
  backgroundColor: 'transperant'
  style: listTitleFontStyle

moreItemText = new L
  x: dp 62
  y: dp 36
  width: WIDTH - dp(80)
  height: dp 13
  html: '휴대폰을 더욱 빠르고 쾌적하게 관리하세요!'
  superLayer: moreItem1
  backgroundColor: 'transperant'
  style: smallFontStyle

moreItem2 = moreItem1.copy()
moreItem2.superLayer = moreContents
moreItem2.y += moreItem1.height + dp(4)
moreItem2.subLayers[0].image = './images/2.png'
moreItem2.subLayers[1].html = '앱 정리'
moreItem2.subLayers[1].style = listTitleFontStyle
moreItem2.subLayers[2].html = '사용하지 않는 앱을 정리해보세요.'
moreItem2.subLayers[2].style = smallFontStyle

refresh = new L
  y: HEIGHT
  width: WIDTH
  height: HEIGHT
  opacity: 0
  backgroundColor: '#333'
refreshButton = new L
  width: dp 56
  height: dp 56
  superLayer: refresh
  image: './images/refresh.png'
refreshButton.center()
refreshGuide = new L
  y: HEIGHT/2 + dp(70)
  width: WIDTH
  height: dp 30
  backgroundColor: 'transperant'
  html: '다시 보기'
  superLayer: refresh
  style: normalFontStyle

refresh.on Events.Click, ->
  window.location.reload()

prototypeEnd = ()->
  refresh.opacity = 1
  refresh.y = 0

executeButton.on Events.Click, ->
  listLabel.opacity = 0
  processRun()
  scene 'down'
  scene 'execute'
  listItems.forEach (item, i)->
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

    # EXECUTION COMPLETE
    Utils.delay 2, ->
      # item.x = 0
      # item.rotation = rotation
      # item.opacity = 1
      # item.scale = 1
      # listLabel.opacity = 1

  Utils.delay 1, ->
    number.html = '00 <span style="font-size:0.4em">%<span>'
    clearInterval interval
  Utils.delay 2, ->
    scene 'executionComplete', time: 2, curve: 'ease'
    Utils.delay 5, ->
      prototypeEnd()
    
capture = 
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

# STATES!
commonState 'searching', { scale: 0, opacity: 1}, [search, searchText]
commonState 'searching', { scale: 0, opacity: 0}, [number, contentText, executeButton]
commonState 'searchDone', { scale: -1, opacity: 1 }, [search, searchText]
commonState 'searchDone', { scale: 1, opacity: 1}, [number, contentText, executeButton]

contentText.states.add
  'up':
    x: dp 8
    y: dp 150
    scale: 0.75
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
    x: dp -70
    y: dp 68
    scale: 0.5
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
    x: WIDTH - executeButton.width - dp(16)
    y: dp 110
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

moreContents.states.add
  'down': 
    y: HEIGHT
  'executionComplete': 
    y: HEIGHT - dp(42) - dp(8)*2 - dp(60)*2 - dp(4)

completeMessage.states.add
  'down': 
    opacity: 0
    y: dp 340
  'executionComplete':
    opacity: 1
    y: dp 297

# EVENT HANDLING
searchStart = ()->
  scene 'searching'
searchDone = ()->
  scene 'searchDone'
  listItems.forEach (item, i)->
    Utils.delay i * 0.05, ->
      item.textToggle()

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
    # console.log 'down'

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

# scenario
searchStart()

Utils.delay 2, ->
  list.draggable.enabled = true
  list.draggable.horizontal = false
  list.on Events.DragMove, listDragMoveFunc
  list.on Events.DragEnd, listDragEndFunc
  searchDone()

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
