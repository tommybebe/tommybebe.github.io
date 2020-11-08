// import {earth, connectButton, connectWrapper, connectWrapperBack} from './layers';
import * as layers from './layers';

layers.earth.states.add('connectStart', {
  y: Screen.height - 420,
});
layers.phone.states.add('connectStart', {
  y: Screen.height - 460,
});

layers.connectWrapper.states.add('expand', {
  opacity: 0
});
layers.users.states.add('expand', {
  opacity: 1
});
layers.close.states.add('expand', {
  opacity: 1
});
layers.signal.states.add('expand', {
  opacity: 1
});
layers.text.states.add('expand', {
  opacity: 1
});
layers.connectButton.states.add('expand', {
  opacity: 1,
  x: 0,
  y: 0,
  width: Screen.width,
  height: Screen.height,
  borderRadius: 0
});
layers.connectWrapperBack.states.add('expand', {
  opacity: 1,
  midX: Screen.width/2,
  midY: Screen.height/2,
  width: Screen.width*2.1,
  height: Screen.width*2.1
});
layers.close.states.add('expand', {
  x: 72,
  y: 72,
  opacity: 1
});

layers.users.subLayers.forEach(function(layer){
  layer.states.add('findDevices', {
    scale: 1
  });
});

layers.user1.states.add('connectRequest', {
  midX: Screen.width/2,
  y: 50
});
layers.user1.states.add('connectRequestHide', {
  y: 300,
  opacity: 0
});
layers.user2.states.add('connectRequest', {
  midX: Screen.width/2,
  y: 50
});
layers.user2.states.add('connectRequestHide', {
  y: 300,
  opacity: 0
});

layers.text.states.add({
  'out': {
    y: 200,
    opacity: 0
  },
  'in': {
    y: 250,
    opacity: 1
  }
});

layers.signalLine1.states.add('connecting', {
  rotation: 48,
});

layers.signalLine2.states.add('connecting', {
  rotation: 43.5,
});

