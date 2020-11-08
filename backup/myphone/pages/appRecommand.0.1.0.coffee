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
  head: '#d3600c'
  label: '#9fa4aa'

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
    'font-size': sp 19
    'line-height': '1em'
    'color': '#fff'
    'font-weight': '500'
  label: 
    'font-size': sp 12
    'line-height': '1em'
    'color': '#fff'
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
  html: '인기 추천 앱'
  backgroundColor: color.head
  style: style.headTitle

class Label extends L
  constructor: (text)->
    super 
      width: WIDTH
      height: dp 32
      html: text
      backgroundColor: color.label
      style: style.label

slideBanner = new PageComponent
  y: dp 80
  width: WIDTH
  height: dp 160
  backgroundColor: '#010100'
slideBanner.centerX()

slideBannerPointers = new L
  superLayer: slideBanner
  y: dp 126
  width: dp 58
  height: dp 9
  backgroundColor: 'transperant'
slideBannerPointers.centerX()
slideBannerPointers.currentPage = 0
slideBannerPointers.pointers = []

[0..3].forEach (i)->
  slide = new L
    superLayer: slideBanner
    x: i * WIDTH
    width: slideBanner.width
    height: slideBanner.height
    backgroundColor: slideBanner.backgroundColor
    image: './images/banner'+i+'.png'
  slideBanner.addPage(slide, "right")

  pointer = new L
    superLayer: slideBannerPointers
    x: i * dp(16)
    width: dp 9
    height: dp 9
    borderRadius: dp 9
    backgroundColor: 'rgba(255, 255, 255, 0.15)'
    style:
      border: dp(1) + 'px solid #fff'
  pointerSelected = new L
    width: dp 9
    height: dp 9
    superLayer: pointer
    backgroundColor: '#fff'
    borderRadius: dp 9
    scale: 0
  pointerSelected.center()
  pointerSelected.states.add
    'pointerOn':
      scale: 1
    'pointerOff':
      scale: 0

  slideBannerPointers.pointers.push pointerSelected

slideBannerPointers.pointers[0].states.switch 'pointerOn'

setInterval ->
  if slideBanner.nextPage()
    slideBanner.snapToNextPage()
    slideBannerPointers.currentPage += 1
  else
    slideBanner.snapToPage()
    slideBannerPointers.currentPage = 0
  scene 'pointerOff'
  slideBannerPointers.pointers[slideBannerPointers.currentPage].states.switch 'pointerOn'
, 5000


list = new L
  y: dp 240
  width: WIDTH
  height: HEIGHT - dp(240)
  backgroundColor: 'transperant'
  image: './images/recommandList.png'

# STATES!



# scenario
