# device setting
Framer.Device.deviceType = "iphone-6-silver"

# variables
screenWidth = Framer.Device.screen.width
screenHeight = Framer.Device.screen.height
color = 
  white: '#fff'
  red: 'rgba(231,76,60,1)'
  blue: 'rgba(52, 152, 219,1.0)'
  gray: 'rgba(189, 189, 189, 1)'
  glass: 'rgba(255,255,255,0.9)'
  darkGlass: 'rgba(0,0,0,0.3)'
index = 
  top: 10000000
aniOpt =
  paper: 
    time: 0.3
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

# Utils
L = Layer
dp = (val)->
  pxToDp = screenWidth / 360
  return Math.round val * pxToDp

class Button extends Layer
  constructor: (options)->
    defulatOptions = x:0, y:0, backgroundColor: 'rgba(0, 0, 255, 1)', width: 56*3, height: 56*3
    options = _.assign defulatOptions, options

    super(options)
    options.index && @index = options.index
    if options.backgroundColor is 'transparent'
      rippleColor = 'rgba(0, 0, 0, 0.3)'
    else 
      rippleColor = 'rgba(255, 255, 255, 0.3)'
    # ripple event sequence.
    # 1. 터치 시작과 함께 터치된 곳에서 0x0 크기 + 0% 투명도를 + parent의 1.5배 scale ripple 이 하나 생겨난다.
    # 2. 터치 release 하기 전까지 애니메이션을 진행하며, 
    # 3. 터치 좌표가 변경될 경우 좌료를 따라 움직인다.
    # 4. 터치 release 되면 ripple을 커지기 전의 상태로 돌린다.
    # 5. 단, 완전히 ripple이 커지기 전에 release 이벤트가 일어나면, 커지는 애니메이션을 기다린 후 뒤의 애니메이션을 진행한다.
    ripple = new Layer width:options.width, height:options.height, backgroundColor: rippleColor
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

id = ->
  '_' + Math.random().toString(36).substr(2, 9)

class Scene
  constructor: ->
    @stateName = id()
    @states = []
    @defaultAniOpt = aniOpt.paper
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



bg = new BackgroundLayer({backgroundColor:"white"})



fab = new Button
  midX: screenWidth/2, midY: screenHeight/2
  width: dp 56
  height: dp 56
  backgroundColor: color.red
fab.borderRadius = '50%'
fab.classList.add 'z-depth-3'
window.onmousemove = (e)->
  rotationX = ((-100 + e.x - fab.midX) / screenWidth / 2) * 100
  rotationY = ((-100 + e.y - fab.midY) / screenHeight / 2) * 100
  fab.rotationY = rotationX
  fab.rotationX = -rotationY


contacts = new L
  x:screenWidth, width: screenWidth, height: screenHeight
  backgroundColor: color.glass
contacts.states.animationOptions = aniOpt.paper
contacts.states.add 'open', x:0, opacity:1
contacts.states.add 'close', x:screenWidth, opacity:0
contacts.states.switchInstant 'open'
toggleContacts = ->
  if contacts.states.state is 'open'
    contacts.states.switch 'close'
  else
    contacts.states.switch 'open'

lnb = new L
  width: screenWidth, height: dp(80)
  backgroundColor: color.white
  superLayer: contacts
lnb.classList.add 'z-depth-1'

back = new Button
  x: dp(16), y: dp(34), width: dp(36), height:dp(36), backgroundColor: 'transparent'
  superLayer: lnb
back.borderRadius = '50%'
back.html = '<span class="icon-close"></span>'
back.on Events.Click, (e, layer)->
  toggleContacts()

searchIcon = new Button
  x: dp(360-16-36), y: dp(34), width: dp(36), height:dp(36), backgroundColor: 'transparent'
  superLayer: lnb
searchIcon.borderRadius = '50%'
searchIcon.html = '<span class="icon-search"></span>'
searchIcon.on Events.Click, (e, layer)->

searchInput = new L
  x: dp(72), y: dp(36), width: dp(360-72-16), height: dp(32), backgroundColor: 'transparent'
  superLayer: lnb
searchInput.html = '<input type="text"/>'

contactList = new L
  y: dp(80), width: screenWidth, height: screenHeight - dp(80), backgroundColor: 'transparent'
  superLayer: contacts

class Contact extends Layer
  constructor: (options)->
    super options

contactItem = new Contact
  width: screenWidth, height: dp(72), backgroundColor: 'transparent'
  superLayer: contactList

user = new L
  x: dp(16), y: dp(16), width: dp(40), height: dp(40), backgroundColor: color.gray
  superLayer: contactItem
user.borderRadius = '50%'
user.html = '<span class="icon-person"></span>'
user.classList.add 'user-picture'

statusBar = new L
  width: screenWidth, height: dp(24)
  backgroundColor: color.darkGlass
statusBar.index = index.top


fab.on Events.Click, (e, layer)->
  toggleContacts()
