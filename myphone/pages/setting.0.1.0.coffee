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
  background: '#f8f8f8'
  head: '#2b487c'
  list: '#f8f8f8'
  listBorder: '#c5c5c5'
  checkbox: 'rgba(93,151,194,1)'

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

style = 
  headTitle:
    'font-size': sp 18
    'line-height': '1em'
    'color': '#fff'
    'font-weight': '500'
  normalFontStyle:
    'font-size': sp 20
    'line-height': '1em'
    'text-align': 'center'
    'color': '#fff'
  listItemTitle:
    'font-size': sp 14
    'line-height': '1em'
    'color': '#252e3e'
    'font-weight': 400
  listItemInfo:
    'font-size': sp 12
    'line-height': '1em'
    'color': '#777777'
    'font-weight': 400
  listItemInfo2:
    'font-size': sp 14
    'line-height': '1em'
    'color': 'rgba(37, 46, 62, 0.8)'
    'font-weight': 400

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

    if options.rippleColor 
      rippleColor = options.rippleColor 
    else if options.backgroundColor is 'transperant'
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
  backgroundColor: color.head
  index: 10000000

statusBar = new L
  superLayer: head
  x: WIDTH - dp(166)
  y: dp 2
  width: dp 160
  height: dp 18
  backgroundColor: 'transperant'
  image: './images/statusBarIcons.png'

closeButton = new L
  x: dp 16
  y: dp 45
  width: dp 15
  height: dp 15
  image: './images/close.png'
  superLayer: head

headTitle = new L
  x: dp 55
  y: dp 44
  width: dp 200
  height: dp 20
  html: '환경설정'
  backgroundColor: color.head
  style: style.headTitle

itemInfos = [
  { type: 'link', title: '정리 제외 앱 설정', info: '최적화로 종료하지 않을 앱을 설정합니다.', linkTo: 'appList' }
  { type: 'link', title: 'PUSH 알림 설정', info: '휴대폰 사용/알림 정보를 수신합니다.', linkTo: 'push' }
  { type: 'checkbox', title: '자동 최적화 사용', info: '화면을 켤 때마다 최적화합니다.' }
  { type: 'checkbox', title: '앱 자동 백업 사용', info: '앱을 삭제하면 복원 목록을 생성합니다.' }
  { type: 'checkbox', title: '절전모드 사용', info: '배터리가 30% 미만일 경우 절전모드를 실행합니다.' }
  { type: 'link', title: '공지사항', linkTo: 'notice' }
  { type: 'link', title: '서비스 이용 문의' }
  { type: 'link', title: '광고/제휴 문의' }
  { type: 'plain', title: '버전 관리', info: '최신 버전입니다.', info2: '3.0.0' }
]

pushContents = [
  { type: 'checkbox', title: '기기 최적화 알림', info: '기기 최적화가 필요할 때 알려줍니다.' }
  { type: 'checkbox', title: '파일 최적화 알림', info: '파일 최적화가 필요할 때 알려줍니다.' }
  { type: 'checkbox', title: '앱 관리 알림', info: '앱 관리가 필요할 때 알려줍니다.' }
  { type: 'checkbox', title: '추천 앱 알림', info: '추천 앱 소식을 알려줍니다.' }
]

noticeContents = [
  { type: 'plain', title: '마이앱 공지 입니다.', info2: '15.09.19' }
  { type: 'plain', title: '마이앱 공지 입니다.', info2: '15.09.19' }
  { type: 'plain', title: '마이앱 공지 입니다.', info2: '15.09.19' }
  { type: 'plain', title: '마이앱 공지 입니다.', info2: '15.09.19' }
  { type: 'plain', title: '마이앱 공지 입니다.', info2: '15.09.19' }
  { type: 'plain', title: '마이앱 공지 입니다.', info2: '15.09.19' }
]

pageMove = (page)->
  pages[page].states.switch 'in'
  pages.main.states.switch 'down'

closeAllPage = ()->
  Object.keys(pages).forEach (page)->
    pages[page].states.switch('out') unless page is 'main'
  pages.main.states.switch 'in'

class ListItem extends Button
  constructor: (parent, seq, item)->
    super _.assign {}, 
      y: dp(seq * 64)
      width: WIDTH
      height: dp 64
      backgroundColor: color.list
      opacity: 1
      rippleColor: 'rgba(0,0,0,0.1)'
      superLayer: parent.content

    if item.type is 'link'
      linkIcon = new L
        x: WIDTH - dp(26)
        y: dp 7
        width: dp 9
        height: dp 15
        image: './images/link-icon.png'
        superLayer: @
      linkIcon.centerY()
    else if item.type is 'plain'
      info2 = new L
        superLayer: @
        x: WIDTH - dp(76)
        width: dp 60
        height: dp 14
        style: style.listItemInfo2
        html: item.info2
        backgroundColor: 'transperant'
      info2.centerY()
    else 
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

    title = new L
      x: dp 16
      y: dp 16
      height: dp 13
      width: dp 200
      superLayer: @
      html: item.title
      style: style.listItemTitle
      backgroundColor: 'transperant'
    title.centerY() unless item.info
    @info = new L
      x: dp 16
      y: dp 38
      height: dp 13
      width: WIDTH - dp(64)
      superLayer: @
      html: item.info
      backgroundColor: 'transperant'
      style: style.listItemInfo
    border = new L
      y: dp 63
      width: WIDTH
      height: 1
      backgroundColor: color.listBorder
      superLayer: @

    @on Events.Click, ->
      return unless item.linkTo
      Utils.delay 0.2, ->
        pageMove item.linkTo

class List extends L
  constructor: (contents)->
    options = 
      y: dp 80
      width: WIDTH
      height: HEIGHT - dp(80)
      backgroundColor: 'transperant'
      brightness: 100
    
    super options

    listItems = []
    @states.add 
      in:
        x: 0
        brightness: 100
      out: 
        x: WIDTH
      down: 
        brightness: 50

    listWrapper = new ScrollComponent
      width: WIDTH
      height: HEIGHT - dp(80)
      backgroundColor: color.list
      superLayer: @

    listWrapper.scrollHorizontal = false
    listWrapper.scrollVertical = true

    contents.forEach (item, i)=>
      listItems.push new ListItem listWrapper, i, item

pages = {}
pages.main = new List itemInfos
pages.push = new List pushContents
pages.notice = new List noticeContents

pages.push.states.switchInstant 'out'
pages.notice.states.switchInstant 'out'

closeButton.on Events.Click, ->
  closeAllPage()


# STATES!


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
