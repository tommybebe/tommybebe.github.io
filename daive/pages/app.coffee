# DEFAULT SETTINGS
Framer.Defaults.Animation = {
  curve: "spring(600,30,5)"
}
Framer.Device.deviceType = "nexus-5-black"


# VARIABLES!
WIDTH = Framer.Screen.width
HEIGHT = Framer.Screen.height

color = 
  background: '#464f6d'
  head: '#000'

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

# TOOLS
mobile = !!(new MobileDetect(window.navigator.userAgent)).phone() if MobileDetect

dp = (num)->
  return num * (if mobile then 2 else 3)

sp = (num)->
  return (num * (if mobile then 2 else 3)) + 'px'

class L extends Layer
  constructor: (options)->
    options.image = './images/' + options.image if options.image
    super _.assign {backgroundColor: 'transperant'}, options

class Button extends Layer
  constructor: (options)->
    defulatOptions = x:0, y:0, backgroundColor: 'transperant', width: 56*3, height: 56*3
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
  Framer.currentContext._layerList.forEach (layer)->
    layer.states.switch(state, option) if layer._states and layer._states._orderedStates.indexOf(state) > 0 

commonState = (name, state, layers)->
  layers.forEach (layer)->
    defaultAttrs = {}
    Object.keys(state).forEach (attr)->
      defaultAttrs[attr] = layer[attr] + state[attr]
    layer.states.add name, defaultAttrs


# LAYERS
background = new BackgroundLayer
  backgroundColor: color.background

# make top bar
head = new L
  width: WIDTH
  height: dp 24
  backgroundColor: color.head

statusBar = new L
  superLayer: head
  x: WIDTH - dp(166)
  y: dp 2
  width: dp 160
  height: dp 18
  image: 'statusBarIcons.png'

list = new ScrollComponent
  x: 0
  y: dp 24
  width: WIDTH
  height: HEIGHT - dp(24)
list.scrollHorizontal = false
list.scrollVertical = true

listItem = [0..5].map (i)->
  item = new L
    superLayer: list.content
    y: i * dp(195) + dp(52)
    width: WIDTH
    height: dp 195
  img = new L
    superLayer: item
    height: dp 150
    width: dp 150
    image: 'item.png'
  img.centerX()

addButton = new Button
  x: WIDTH - dp(72)
  y: dp 40
  width: dp 56
  height: dp 56
  borderRadius: dp 56
  rippleColor: 'rgba(255,255,255,0.1)'

addIcon = new L
  superLayer: addButton
  width: dp 24
  height: dp 24
  image: 'ic_add_white_48px.svg'
addIcon.center()

settingButton = new Button
  x: dp(16)
  y: HEIGHT - dp(72)
  width: dp 56
  height: dp 56
  borderRadius: dp 56
  rippleColor: 'rgba(255,255,255,0.1)'

settingIcon = new L
  superLayer: settingButton
  width: dp 24
  height: dp 24
  image: 'ic_settings_white_48px.svg'
settingIcon.center()

viewButton = new Button
  x: WIDTH - dp(72)
  y: HEIGHT - dp(72)
  width: dp 56
  height: dp 56
  borderRadius: dp 56
  rippleColor: 'rgba(255,255,255,0.1)'

viewIcon = new L
  superLayer: viewButton
  width: dp 24
  height: dp 24
  image: 'ic_today_white_48px.svg'
viewIcon.center()


# states!
