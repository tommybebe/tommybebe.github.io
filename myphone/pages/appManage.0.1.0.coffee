Framer.Defaults.Animation = {
  curve: "spring(300,30,0)"
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
  manageMenuButton: '#777777'

aniOpt =
  paper: 
    time: 0.3
    curve: 'ease-out'
  spring:
    time: 0.1
    curve: 'spring'
    curveOptions:
      tension: 400
      friction: 20
      velocity: 10
  ripple:
    time: 0.4
    curve: 'cubic-bezier(0,1,1,1)'

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
  filter:
    'font-size': sp 14
    'line-height': '1em'
  filterDropdownTitle:
    'font-size': sp 14
    'line-height': '1em'
    'color': '#252e3e'
  filterText: 
    'font-size': sp 12
    'line-height': '1em'
    'color': '#777777'
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
  manageMenuButton: 
    'font-size': sp 13
    'padding-top': sp 8
    'padding-left': sp 25
    'line-height': '1em'
    'color': '#777777'
    'font-weight': '400'

background = new BackgroundLayer
  backgroundColor: color.background

_layers = []

class L extends Layer
  constructor: (options)->
    super options
    _layers.push @

class Button extends Layer
  constructor: (options)->
    defulatOptions = x:0, y:0, backgroundColor: 'rgba(0, 0, 255, 1)', width: 56*3, height: 56*3
    options = _.assign defulatOptions, options

    super(options)
    options.index && @index = options.index

    if options.shadowColor
      @.states.add
        pushed: { scale: 1, shadowY: 0, shadowBlur: 0, shadowSpread: 0 }
        normal: { scale: 1, shadowY: options.shadowY, shadowBlur: options.shadowBlur, shadowSpread: options.shadowSpread }
    else 
      @.states.add
        pushed: { scale: 1 }
        normal: { scale: 1 }

    @.states.animationOptions = aniOpt.spring

    if options.backgroundColor is 'transperant'
      rippleColor = 'rgba(0, 0, 0, 0.1)'
    else 
      rippleColor = 'rgba(255, 255, 255, 0.1)'
    rippleSize = if options.width > options.height then options.width else options.height
    # ripple event sequence.
    # 1. 터치 시작과 함께 터치된 곳에서 0x0 크기 + 0% 투명도를 + parent의 1.5배 scale ripple 이 하나 생겨난다.
    # 2. 터치 release 하기 전까지 애니메이션을 진행하며, 
    # 3. 터치 좌표가 변경될 경우 좌료를 따라 움직인다.
    # 4. 터치 release 되면 ripple을 커지기 전의 상태로 돌린다.
    # 5. 단, 완전히 ripple이 커지기 전에 release 이벤트가 일어나면, 커지는 애니메이션을 기다린 후 뒤의 애니메이션을 진행한다.
    ripple = new Layer width:rippleSize, height:rippleSize, backgroundColor: rippleColor
    ripple.superLayer = @
    ripple.borderRadius = @width
    ripple.states.add 'focus', scale: 1.5, opacity: 1
    ripple.states.add 'blur', scale: 1.6, opacity: 0
    ripple.states.add 'off', scale: 0, opacity: 0
    ripple.states.animationOptions = aniOpt.ripple
    ripple.states.switchInstant 'off'

    focusEnd = (e, layer)->
      ripple.focusEnd = true
    blurStart = (e, layer)=>
      ripple.focusEnd = false
      ripple.states.switch 'blur'

    @on Events.TouchStart, (e, layer)->
      e.stopPropagation()
      # ios 에서는 이벤트 객체가 뭔가 다름.
      if e.changedTouches and e.changedTouches[0]
        x = e.changedTouches[0].clientX - @x
        y = e.changedTouches[0].clientY - @y
      else
        x = e.offsetX
        y = e.offsetY
            
      ripple.states.switchInstant 'off'
      ripple.midX = x
      ripple.midY = y
      ripple.states.switch 'focus'
      ripple.once Events.AnimationEnd, focusEnd

      @.states.switch 'pushed'

    @on Events.TouchEnd, (e, layer)=>
      # 애니메이션 끝나고, 홀드된 상태
      if ripple.focusEnd
        ripple.states.switch 'blur'
      # 애니메이션 끝내기 전에 손을 뗀 경우 기다린 다음 애니메이션 진행
      else
        ripple.once Events.AnimationEnd, blurStart
      @.states.switch 'normal'
      ripple.focusEnd = false

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
  html: '앱정리'
  backgroundColor: color.head
  style: style.headTitle

filter = new L
  x: dp 8
  y: dp 88
  width: dp 135
  height: dp 27
  backgroundColor: 'transperant'

filterText = new L
  x: dp 8
  y: dp 12
  width: filter.width
  height: dp 15
  superLayer: filter
  html: '실행 횟수 적은 앱'
  backgroundColor: 'transperant'
  style: style.filter

filterIcon = new L
  x: filter.width - dp(7)
  y: filter.height - dp(7)
  width: dp 14
  height: dp 14
  rotation: 45
  superLayer: filter
  backgroundColor: '#fff'

filterDropdown = new L
  x: dp 15
  y: dp 124
  width: dp 170
  height: 0
  backgroundColor: '#fff'

filterDropdownTitle = new L
  x: dp 25
  y: dp 25
  width: dp 145
  height: dp 14
  html: '정렬 방법'
  superLayer: filterDropdown
  backgroundColor: 'transperant'
  style: style.filterDropdownTitle

filters = ['용량 큰 앱', '용량 작은 앱', '실행 횟수 많은 앱', '실행 횟수 적은 앱', '실행 시간 많은 앱', '실행 시간 적은 앱']

class FilterItem extends L
  constructor: (seq)->
    super
      x: dp 25
      y: (dp(33) * seq) + dp(58)
      width: dp 120
      height: dp 15
      superLayer: filterDropdown
      backgroundColor: 'transperant'

    @radio = new L
      y: dp 2
      width: dp 9
      height: dp 9
      superLayer: @
      backgroundColor: 'transperant'
      borderRadius: dp 9
      style:
        border: dp(1)+'px solid #888888'

    @radioSelected = new L
      width: dp 9
      height: dp 9
      superLayer: @radio
      backgroundColor: '#888888'
      borderRadius: dp 9
      scale: 0
    @radioSelected.center()
    @radioSelected.states.add
      'on':
        scale: 1
      'off':
        scale: 0

    @text = new L
      x: dp 15
      width: dp 120
      height: dp 13
      html: filters[seq]
      style: style.filterText
      backgroundColor: 'transperant'
      superLayer: @

    @on Events.Click, ->
      filterLayers.forEach (item, i)->
        item.off()
      @radioSelected.states.switch 'on'
      filterText.html = @text.html
      sort()
      Utils.delay 0.2, ->
        filterDropdown.states.switch 'default'

  off: ()->
    @radioSelected.states.switch 'off'

filterLayers = []
filters.forEach (item, i)->
  filterLayers.push new FilterItem i


listItems = []
itemInfos = [
  { title: '카카오톡', info: '42.2MB 사용', icon: './images/app0.png' }
  { title: '쿠팡 - 소셜 커머스', info: '256.1MB 사용', icon: './images/app1.png' }
  { title: '알송 모바일 - mp3 뮤직 플레이어', info: '256.1MB 사용', icon: './images/app2.png' }
  { title: 'Tranvalloon 트래벌룬', info: '235MB 사용', icon: './images/app3.png' }
  { title: '엔젤스톤 with NAVER', info: '777MB 사용', icon: './images/app4.png' }
  { title: '카카오택시 kakaoTaxi', info: '256.1MB 사용', icon: './images/app5.png' }
  { title: '옥션 kakaoTaxi', info: '256.1MB 사용', icon: './images/app6.png' }
  { title: 'V - 스타 레알 라이브 방송 앱', info: '256.1MB 사용', icon: './images/app7.png' }
  { title: '카카오톡', info: '42.2MB 사용', icon: './images/app0.png' }
  { title: '쿠팡 - 소셜 커머스', info: '256.1MB 사용', icon: './images/app1.png' }
  { title: '알송 모바일 - mp3 뮤직 플레이어', info: '256.1MB 사용', icon: './images/app2.png' }
  { title: 'Tranvalloon 트래벌룬', info: '235MB 사용', icon: './images/app3.png' }
  { title: '엔젤스톤 with NAVER', info: '777MB 사용', icon: './images/app4.png' }
  { title: '카카오택시 kakaoTaxi', info: '256.1MB 사용', icon: './images/app5.png' }
  { title: '옥션 kakaoTaxi', info: '256.1MB 사용', icon: './images/app6.png' }
  { title: 'V - 스타 레알 라이브 방송 앱', info: '256.1MB 사용', icon: './images/app7.png' }
]

list = new L
  x: dp 0
  y: dp 135
  width: WIDTH
  height: HEIGHT - dp(135)
  backgroundColor: 'transperant'
  index: 900

listWrapper = new ScrollComponent
  width: WIDTH
  height: HEIGHT - dp(135)
  backgroundColor: color.background
  superLayer: list
  index: 910
listWrapper.scrollHorizontal = false
listWrapper.scrollVertical = true
listWrapper.mouseWheelEnabled = true


class ListItem extends Button
  constructor: (seq, item)->
    super _.assign {}, 
      y: dp(seq * 64)
      width: WIDTH
      height: dp 64
      backgroundColor: color.list
      opacity: 1
      superLayer: listWrapper.content
    @states.add
      'hide':
        opacity: 0
    icon = new L
      x: dp 12
      y: dp 12
      width: dp 40
      height: dp 40
      image: item.icon
      superLayer: @
    @manage = new Button
      x: WIDTH - dp(32) - dp(16)
      y: dp 16
      width: dp 32
      height: dp 32
      borderRadius: dp 4
      backgroundColor: 'rgb(59, 93, 122)'
      superLayer: @
    @manage.on Events.Click, ->
      manageMenuTitle.html = item.title
      manageMenu.states.switch 'show'
    @manageIcon = new L
      x: dp 7
      y: dp 7
      width: dp 18
      height: dp 18
      image: './images/manage-icon.png'
      superLayer: @manage
    title = new L
      x: dp 70
      y: dp 14
      height: dp 13
      width: dp 200
      superLayer: @
      html: item.title
      style: style.listItemTitle
      backgroundColor: 'transperant'
    @info = new L
      x: dp 70
      y: dp 38
      height: dp 13
      width: dp 200
      superLayer: @
      html: item.info
      backgroundColor: 'transperant'
      style: style.listItemInfo
    border = new L
      width: WIDTH
      height: 1
      backgroundColor: color.listBorder
      superLayer: @

itemInfos.forEach (item, i)->
  listItems.push new ListItem i, item

manageMenu = new L
  y: HEIGHT
  width: dp 196
  height: dp 232
  opacity: 0
  backgroundColor: '#fff'
manageMenu.centerX()

manageMenuTitle = new L
  x: dp 25
  y: dp 25
  width: dp 145
  height: dp 14
  html: '카카오톡'
  superLayer: manageMenu
  backgroundColor: 'transperant'
  style: style.filterDropdownTitle

buttonTexts = ['실행하기', '삭제하기', '백업하기', '정보보기', '홈화면에 바로가기 설정']
buttons = []
buttonTexts.forEach (text, i)->
  b = new Button
    y: (dp(34) * i) + dp(51)
    width: dp 232
    height: dp 30
    backgroundColor: 'transperant'
    html: text
    superLayer: manageMenu
    style: style.manageMenuButton
  b.on Events.Click, ->
    Utils.delay 0.5, ->
      manageMenu.states.next()


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


# STATES!
filterDropdown.states.add 
  show:
    height: dp 258

manageMenu.states.add
  'show':
    y: (HEIGHT - manageMenu.height)/2
    opacity: 1

# EVENT HANDLING
filter.on Events.Click, ->
  filterDropdown.states.next()

sort = ()->
  console.log 'sort!'


# scenario


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
