_ = Framer._

# Define screen category and size, and dp
md = new MobileDetect(window.navigator.userAgent)

device =
  width: Framer.Device.screen.width
  height: Framer.Device.screen.height

dpFuncMaker = (dpx)->
  (n)->
    dpx * n

# 전화기인 경우 풀 사이즈 출력, Framer.Device.screen 정보 조회 후 width/dp 결정
# Framer.Device.screen.width 구해서 window.devicePixelRatio로 나눔.
# dp계산시의 곱 계수는 window.devicePixelRatio가 됨.
if md.phone()
  dpx = window.devicePixelRatio
# 타블렛인 경우 풀 사이즈 출력하지 않고, 절반 사이즈로 여백을 더함. 나머지 계산은 전화기와 동일
# Framer.Device.screen.width 구해서 window.devicePixelRatio로 나눔. 여기서 절반만 씀.
# dp계산시의 곱 계수는 window.devicePixelRatio/2가 됨.
# 화면에 여백 절반 더함.
else if md.tablet()
  dpx = window.devicePixelRatio / 2
  device.width = device.width / 2
  device.height = device.height / 2
# PC인 경우 넥서스5로 설정. 1080 x 1920,  width=360dp
# dp 계수는 강제 3
else
  dpx = 2
  Framer.Device.deviceType = "iphone-6-silver"
  # Framer.Device.deviceType = "nexus-5-black"
  device =
    width: Framer.Device.screen.width
    height: Framer.Device.screen.height

dp = dpFuncMaker dpx

# variables
color = 
  white: '#fff'
  red: 'rgba(231,76,60,1)'
  green: '#4CAF50'
  blue: 'rgba(52, 152, 219,1.0)'
  gray: 'rgba(189, 189, 189, 1)'
  glass: 'rgba(255,255,255,0.9)'
  darkGlass: 'rgba(0,0,0,0.3)'
index = 
  five: 100000000
  four: 1000000
  three: 10000
  two:  100
  one:  1
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
    time: 0.5
    curve: 'ease-out'

# Utils
L = Layer

class Button extends Layer
  constructor: (options)->
    defulatOptions = x:0, y:0, backgroundColor: 'rgba(0, 0, 255, 1)', width: 56*3, height: 56*3
    options = _.assign defulatOptions, options

    super(options)
    options.index && @index = options.index

    if options.shadowColor
      @.states.add
        pushed: { scale: 0.9, shadowY: 0, shadowBlur: 0, shadowSpread: 0 }
        normal: { scale: 1, shadowY: options.shadowY, shadowBlur: options.shadowBlur, shadowSpread: options.shadowSpread }
    else 
      @.states.add
        pushed: { scale: 0.9 }
        normal: { scale: 1 }

    @.states.animationOptions = aniOpt.spring

    if options.backgroundColor is 'transparent'
      rippleColor = 'rgba(0, 0, 0, 0.2)'
    else 
      rippleColor = 'rgba(255, 255, 255, 0.3)'
    rippleSize = if options.width > options.height then options.width else options.height
    # ripple event sequence.
    # 1. 터치 시작과 함께 터치된 곳에서 0x0 크기 + 0% 투명도를 + parent의 1.5배 scale ripple 이 하나 생겨난다.
    # 2. 터치 release 하기 전까지 애니메이션을 진행하며, 
    # 3. 터치 좌표가 변경될 경우 좌료를 따라 움직인다.
    # 4. 터치 release 되면 ripple을 커지기 전의 상태로 돌린다.
    # 5. 단, 완전히 ripple이 커지기 전에 release 이벤트가 일어나면, 커지는 애니메이션을 기다린 후 뒤의 애니메이션을 진행한다.
    ripple = new Layer width:rippleSize, height:rippleSize, backgroundColor: rippleColor
    ripple.superLayer = @
    ripple.borderRadius = '50%'
    ripple.states.add 'focus', scale: 2, opacity: 1
    ripple.states.add 'blur', scale: 2.4, opacity: 0
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

id = ->
  '_' + Math.random().toString(36).substr(2, 9)

class Scene
  constructor: ->
    @stateName = id()
    @states = []
    @defaultAniOpt = aniOpt.paper
  add: (layer, options, animation)->
    if _.isString options
      @states.push
        layer: layer
        animation: animation
        stateName: options
    else
      layer.states.add @stateName, options
      @states.push
        layer: layer
        animation: animation
  run: (instant)->
    @states.forEach (item)=>
      _animation = item.layer.states.animationOptions
      item.layer.states.animationOptions = item.animation || if _.isEmpty _animation then @defaultAniOpt else _animation
      stateName = item.stateName || @stateName
      if instant
        item.layer.states.switchInstant stateName
      else
        item.layer.states.switch stateName
      item.layer.states.animationOptions = _animation
    
    after = (cb)=>
      _cb = (e, layer)=>
        @states[0].layer.off Events.AnimationStop, _cb
        cb()
      @states[0].layer.on Events.AnimationStop, _cb

    return { after: after }


class ToggleLayer extends Layer
  constructor: (options, open, close)->
    super options
    @states.animationOptions = aniOpt.paper
    @states.add 'open', open || { x:0, opacity:1 }
    @states.add 'close', close || { x:device.width, opacity:0 }
    @toggle = ->
      if @states.state is 'open'
        @states.switch 'close'
      else
        @states.switch 'open'


class Radio extends Layer
  constructor: (options, check)->
    @checkColor = color.green
    @uncheckColor = '#5a5a5a'
    options = x: options.x, y: options.y, width: dp(20), height: dp(20), backgroundColor: @uncheckColor, superLayer:options.superLayer
    super options
    @borderRadius = '50%'
    @force2d = true
    @clip = false

    inner = new Layer midX:@width/2, midY:@height/2, width:@width-dp(4), height:@height-dp(4), backgroundColor:color.white, superLayer:@
    inner.borderRadius = '50%'

    @checked = new Layer midX:@width/2, midY:@height/2, width:@width-dp(10), height:@height-dp(10), backgroundColor:@checkColor, superLayer:@
    @checked.borderRadius = '50%'
    @checked.scale = 0
    @checked.states.add 'true', scale: 1
    @checked.states.add 'false', scale: 0
    @checked.states.animationOptions = aniOpt.spring
      # curve: 'spring(1000, 10, 10)'

    ripple = new Button midX:@width/2, midY:@height/2, width:@width*2.2, height:@height*2.2, backgroundColor:'transparent', superLayer:@
    ripple.borderRadius = '50%'

    if check
      @checked.states.switchInstant 'true'
    else
      @checked.states.switchInstant 'false'

    @on Events.Click, ->
      @toggle()

  toggle: Utils.debounce 0.1, ->
    if @checked.states.state is 'true'
      @backgroundColor = @uncheckColor
      @checked.states.switch 'false'
    else
      @backgroundColor = @checkColor
      @checked.states.switch 'true'


bg = new BackgroundLayer({backgroundColor:"white"})

fab = new Button
  midX: device.width/3, midY: device.height/2
  width: dp 56
  height: dp 56
  backgroundColor: color.red
  shadowY: 12
  shadowBlur: 10
  shadowSpread: 4
  shadowColor: 'rgba(0,0,0,0.2)'

fab.index = index.five
fab.borderRadius = '50%'

fabAddIcon = new L
  midX: fab.width/2, midY: fab.height/2, width: dp(40), height: dp(40), backgroundColor: 'transparent', superLayer:fab
fabAddIcon.html = '<span class="fab icon icon-add"></span>'
fabDoneIcon = new L
  midX: fab.width/2, midY: fab.height/2, width: dp(40), height: dp(40), backgroundColor: 'transparent', opacity:0, superLayer:fab
fabDoneIcon.html = '<span class="fab icon icon-done"></span>'

fab.states.animationOptions = aniOpt.spring

backSide = new Layer
  midX: device.width/3*2+dp(2)
  y: 0
  width: dp 3
  height: device.height
  backgroundColor: color.gray

fabSide = new Layer
  x: device.width/3*2-dp(10)
  midY: device.height/2
  width: dp 3
  height: dp 56
  backgroundColor: color.red
  clip: false

fabSide.states.add
  pushed: x: device.width/3*2-dp(3)
fabSide.states.animationOptions = aniOpt.spring

fab.on Events.TouchStart, ->
  fabSide.states.switch 'pushed'

fab.on Events.TouchEnd, ->
  fabSide.states.switch 'default'