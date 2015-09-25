# DEFAULT SETTINGS
Framer.Defaults.Animation = {
  curve: "spring(600,30,5)"
}
Framer.Device.deviceType = "nexus-5-black"


# VARIABLES!
WIDTH = Framer.Screen.width
HEIGHT = Framer.Screen.height

color = 
  background: '#0d1623'


# TOOLS
mobile = !!(new MobileDetect(window.navigator.userAgent)).phone() if MobileDetect

dp = (num)->
  return num * (if mobile then 2 else 3)

sp = (num)->
  return (num * (if mobile then 2 else 3)) + 'px'
class L extends Layer
  constructor: (options)->
    super options

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
  height: dp 80
  backgroundColor: 'transperant'
