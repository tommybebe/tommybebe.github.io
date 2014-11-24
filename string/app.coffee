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
  top: 10000000
aniOpt =
  paper: 
    time: 0.3
    curve: 'ease-out'
  spring:
    time: 0.1
    curve: 'spring'
    curveOptions:
      tension: 500
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
    blurStart = (e, layer)->
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
  midX: device.width/2, midY: device.height/2
  width: dp 56
  height: dp 56
  backgroundColor: color.red
fab.borderRadius = '50%'
fab.classList.add 'z-depth-3'

fabAddIcon = new L
  midX: fab.width/2, midY: fab.height/2, width: dp(40), height: dp(40), backgroundColor: 'transparent', superLayer:fab
fabAddIcon.html = '<span class="fab icon icon-add"></span>'
fabDoneIcon = new L
  midX: fab.width/2, midY: fab.height/2, width: dp(40), height: dp(40), backgroundColor: 'transparent', opacity:0, superLayer:fab
fabDoneIcon.html = '<span class="fab icon icon-done"></span>'

fab.states.animationOptions = aniOpt.spring
fab.states.add 'defalut',
  x: device.width - fab.width - dp(16)
  y: device.height - fab.height - dp(16)
  scale: 1
fab.states.add 'hide',
  x: device.width - fab.width - dp(16)
  y: device.height - fab.height - dp(16)
  scale: 0

fab.on Events.Click, (e, layer)->
  if layer.states.state is 'defalut'
    contacts.toggle()
    reminderPop.toggle()
    reminderPopClose.toggle()
    contacts.blur = 0
    remindUser.scale = 0
  else 
    layer.states.switch 'hide'
    contacts.toggle()


# window.onmousemove = (e)->
#   rotationX = ((-100 + e.x - fab.midX) / device.width / 2) * 100
#   rotationY = ((-100 + e.y - fab.midY) / device.height / 2) * 100
#   fab.rotationY = rotationX
#   fab.rotationX = -rotationY


contacts = new ToggleLayer
  x:device.width, width: device.width, height: device.height, backgroundColor: color.glass

lnb = new L
  width: device.width, height: dp(80)
  backgroundColor: color.white
  superLayer: contacts
lnb.classList.add 'z-depth-1'

back = new Button
  x: dp(16), y: dp(34), width: dp(40), height:dp(40), backgroundColor: 'transparent'
  superLayer: lnb
back.borderRadius = '50%'
back.html = '<span class="icon icon-close"></span>'
back.on Events.Click, (e, layer)->
  contacts.toggle()

searchIcon = new Button
  x: device.width-dp(16+40), y: dp(33), width: dp(40), height:dp(40), backgroundColor: 'transparent'
  superLayer: lnb
searchIcon.borderRadius = '50%'
searchIcon.html = '<span class="icon icon-search"></span>'
searchIcon.on Events.Click, (e, layer)->

searchInput = new L
  x: device.width, y: dp(40), width: device.width-dp(72), height: dp(32), opacity:0, backgroundColor: 'transparent'
  superLayer: lnb
searchInput.html = '<input type="text" placeholder="Search"/>'

searchClose = new L
  x: device.width-dp(16+40), y: dp(40), width: dp(32), height: dp(32), opacity:0, backgroundColor: 'transparent'
  superLayer: lnb
searchInput.html = '<input type="text" placeholder="Search"/>'

searchStart = new Scene()
searchStart.add searchIcon, opacity:0
searchStart.add searchInput, opacity:1, x: dp(72)

searchEnd = new Scene()
searchEnd.add searchIcon, opacity:1
searchEnd.add searchInput, opacity:0, x: device.width

searchIcon.on Events.Click, (e, layer)->
  searchStart.run()


contactList = new L
  y: dp(80), width: device.width, height: device.height - dp(80), backgroundColor: 'transparent'
  superLayer: contacts
contactList.scroll = true

reminderPopClose = new ToggleLayer x:device.width, width: device.width, height: device.height, backgroundColor: 'transparent'

remindUser = new Layer width:dp(40), height:dp(40), scale:0
remindUser.borderRadius = '50%'

reminderPop = new ToggleLayer { x: device.width, y: dp(24), width: device.width-dp(72), height: device.height-dp(24), backgroundColor: color.glass }, { x: dp(72), opacity: 1 }
reminderPop.classList.add 'z-depth-3'
reminderPop.on Events.Click, ->


class ReminderSetting extends Layer
  constructor: (index, labelText)->
    super
      y: device.height/7+(index*dp(72)), width: device.width-dp(72), height: dp(72), backgroundColor: 'transparent'
    radio = new Radio x:dp(26), y:dp(26), superLayer:@
    label = new L x:dp(72), y:dp(26), width:device.width-dp(72+72), backgroundColor: 'transparent', superLayer: @
    label.html = '<div class="label">'+labelText+'</div>'

class Contact extends Button
  constructor: (index, data)->
    super
      y: dp(8)+(index*dp(72)), width: device.width, height: dp(72), backgroundColor: 'transparent'

    picture = new Layer
      x: dp(16), y: dp(16), width: dp(40), height: dp(40), image: data.picture, superLayer: @
    picture.borderRadius = '50%'

    name = new Layer
      x: dp(72), y: dp(26), width: device.width-dp(72+72), backgroundColor: 'transparent', superLayer: @
    name.html = '<h3 class="person-name">'+data.name+'</h3>'


reminderPopClose.on Events.Click, ->
  reminderPop.toggle()
  reminderPopClose.toggle()
  contacts.blur = 0
  remindUser.scale = 0


contactsData = [{'name':'simpson lewis','email':'lewis.simpson44@example.com','phone':'(575)-729-8783','picture':'http://api.randomuser.me/portraits/med/men/77.jpg'},{'name':'neal dean','email':'dean.neal71@example.com','phone':'(930)-520-7208','picture':'http://api.randomuser.me/portraits/med/men/27.jpg'},{'name':'snyder jim','email':'jim.snyder17@example.com','phone':'(761)-678-5746','picture':'http://api.randomuser.me/portraits/med/men/99.jpg'},{'name':'holland reginald','email':'reginald.holland23@example.com','phone':'(385)-382-3964','picture':'http://api.randomuser.me/portraits/med/men/88.jpg'},{'name':'nichols maureen','email':'maureen.nichols47@example.com','phone':'(499)-776-1889','picture':'http://api.randomuser.me/portraits/med/women/50.jpg'},{'name':'alexander abigail','email':'abigail.alexander84@example.com','phone':'(728)-873-5092','picture':'http://api.randomuser.me/portraits/med/women/73.jpg'},{'name':'flores caroline','email':'caroline.flores35@example.com','phone':'(746)-797-7001','picture':'http://api.randomuser.me/portraits/med/women/45.jpg'},{'name':'gardner soham','email':'soham.gardner40@example.com','phone':'(235)-493-5463','picture':'http://api.randomuser.me/portraits/med/men/36.jpg'},{'name':'jensen armando','email':'armando.jensen61@example.com','phone':'(849)-136-3128','picture':'http://api.randomuser.me/portraits/med/men/84.jpg'},{'name':'garza kathy','email':'kathy.garza17@example.com','phone':'(939)-257-1162','picture':'http://api.randomuser.me/portraits/med/women/90.jpg'},{'name':'garza theodore','email':'theodore.garza39@example.com','phone':'(334)-380-1887','picture':'http://api.randomuser.me/portraits/med/men/55.jpg'},{'name':'graves rene','email':'rene.graves26@example.com','phone':'(224)-718-5960','picture':'http://api.randomuser.me/portraits/med/men/18.jpg'},{'name':'jackson alice','email':'alice.jackson21@example.com','phone':'(386)-163-3197','picture':'http://api.randomuser.me/portraits/med/women/33.jpg'},{'name':'adams tomothy','email':'tomothy.adams10@example.com','phone':'(584)-602-7508','picture':'http://api.randomuser.me/portraits/med/men/13.jpg'},{'name':'barnes joe','email':'joe.barnes54@example.com','phone':'(321)-788-2852','picture':'http://api.randomuser.me/portraits/med/men/36.jpg'},{'name':'long candice','email':'candice.long73@example.com','phone':'(659)-213-3150','picture':'http://api.randomuser.me/portraits/med/women/81.jpg'},{'name':'schmidt levi','email':'levi.schmidt72@example.com','phone':'(335)-164-1701','picture':'http://api.randomuser.me/portraits/med/men/87.jpg'},{'name':'cole virgil','email':'virgil.cole38@example.com','phone':'(211)-544-3174','picture':'http://api.randomuser.me/portraits/med/men/41.jpg'},{'name':'price annette','email':'annette.price29@example.com','phone':'(385)-704-9883','picture':'http://api.randomuser.me/portraits/med/women/96.jpg'},{'name':'myers duane','email':'duane.myers30@example.com','phone':'(423)-209-6890','picture':'http://api.randomuser.me/portraits/med/men/88.jpg'},{'name':'fowler bob','email':'bob.fowler86@example.com','phone':'(645)-412-1125','picture':'http://api.randomuser.me/portraits/med/men/98.jpg'},{'name':'reynolds terri','email':'terri.reynolds73@example.com','phone':'(100)-509-2414','picture':'http://api.randomuser.me/portraits/med/women/79.jpg'},{'name':'johnson kaylee','email':'kaylee.johnson66@example.com','phone':'(108)-839-9944','picture':'http://api.randomuser.me/portraits/med/women/58.jpg'},{'name':'bradley lily','email':'lily.bradley81@example.com','phone':'(216)-732-4939','picture':'http://api.randomuser.me/portraits/med/women/23.jpg'},{'name':'gutierrez june','email':'june.gutierrez98@example.com','phone':'(896)-233-6708','picture':'http://api.randomuser.me/portraits/med/women/68.jpg'},{'name':'murphy sylvia','email':'sylvia.murphy68@example.com','phone':'(489)-525-7620','picture':'http://api.randomuser.me/portraits/med/women/31.jpg'},{'name':'wheeler priscilla','email':'priscilla.wheeler98@example.com','phone':'(893)-595-1659','picture':'http://api.randomuser.me/portraits/med/women/55.jpg'},{'name':'morales hailey','email':'hailey.morales20@example.com','phone':'(452)-543-9678','picture':'http://api.randomuser.me/portraits/med/women/2.jpg'},{'name':'ward bruce','email':'bruce.ward54@example.com','phone':'(393)-387-5693','picture':'http://api.randomuser.me/portraits/med/men/89.jpg'},{'name':'warren beth','email':'beth.warren76@example.com','phone':'(625)-169-1077','picture':'http://api.randomuser.me/portraits/med/women/7.jpg'},{'name':'cruz adrian','email':'adrian.cruz45@example.com','phone':'(717)-233-7500','picture':'http://api.randomuser.me/portraits/med/men/62.jpg'},{'name':'hunt gilbert','email':'gilbert.hunt11@example.com','phone':'(604)-730-4186','picture':'http://api.randomuser.me/portraits/med/men/45.jpg'},{'name':'lynch evan','email':'evan.lynch37@example.com','phone':'(169)-631-2429','picture':'http://api.randomuser.me/portraits/med/men/94.jpg'},{'name':'lopez fred','email':'fred.lopez71@example.com','phone':'(102)-562-9957','picture':'http://api.randomuser.me/portraits/med/men/45.jpg'},{'name':'martinez hunter','email':'hunter.martinez90@example.com','phone':'(908)-839-8299','picture':'http://api.randomuser.me/portraits/med/men/0.jpg'},{'name':'wilson charlie','email':'charlie.wilson84@example.com','phone':'(121)-832-5699','picture':'http://api.randomuser.me/portraits/med/men/56.jpg'},{'name':'carlson carrie','email':'carrie.carlson34@example.com','phone':'(713)-992-5808','picture':'http://api.randomuser.me/portraits/med/women/0.jpg'},{'name':'taylor nicholas','email':'nicholas.taylor97@example.com','phone':'(458)-651-8087','picture':'http://api.randomuser.me/portraits/med/men/83.jpg'},{'name':'harper gary','email':'gary.harper91@example.com','phone':'(131)-562-8120','picture':'http://api.randomuser.me/portraits/med/men/20.jpg'},{'name':'holt connie','email':'connie.holt56@example.com','phone':'(173)-946-5481','picture':'http://api.randomuser.me/portraits/med/women/17.jpg'}]
contactsData.forEach (data, index)->
  item = new Contact index, data
  item.superLayer = contactList
  item.on Events.Click, ->
    reminderPop.toggle()
    reminderPopClose.toggle()
    contacts.blur = 8

    remindUser.image = data.picture
    remindUser.scale = 1
    remindUser.x = dp 16
    remindUser.y = item.y + dp(26+70)


reminderSettingOptions = [ 'Every day', 'Every Week', 'Every 2 Week', 'Every Month', 'Every 2 Month', 'Every Year']
reminderSettingOptions.forEach (option, index)->
  setting = new ReminderSetting index, option
  setting.superLayer = reminderPop
  setting.on Events.Click, (e, layer)->
    layer.subLayers[0].toggle()

    fab.index = 1000000000000
    fab.states.switch 'defalut'

# user = new L
#   x: dp(16), y: dp(16), width: dp(40), height: dp(40), backgroundColor: color.gray
#   superLayer: contactItem
# user.borderRadius = '50%'
# user.html = '<span class="icon-person"></span>'
# user.classList.add 'user-picture'

statusBar = new L
  width: device.width, height: dp(24)
  backgroundColor: color.darkGlass
statusBar.index = index.top



