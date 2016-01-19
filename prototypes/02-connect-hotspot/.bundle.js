(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){

/**
 * Welcome to Framer
 *
 * Learn how to prototype:
 * - http://framerjs.com/learn
 * - https://github.com/peteschaffner/framer-cli
 */
'use strict';

require('./scripts/controller');

},{"./scripts/controller":5}],2:[function(require,module,exports){
exports.Pointer = (function() {
  var clientCoords, coords, offsetArgumentError, offsetCoords, screenArgumentError;

  function Pointer() {}

  Pointer.screen = function(event, layer) {
    var e, screenCoords;
    if (!((event != null) && (layer != null))) {
      screenArgumentError();
    }
    e = offsetCoords(event);
    if (e.x && e.y) {
      screenCoords = layer.screenFrame;
      e.x += screenCoords.x;
      e.y += screenCoords.y;
    } else {
      e = clientCoords(event);
    }
    return e;
  };

  Pointer.offset = function(event, layer) {
    var e, targetScreenCoords;
    if (!((event != null) && (layer != null))) {
      offsetArgumentError();
    }
    e = offsetCoords(event);
    if (!((e.x != null) && (e.y != null))) {
      e = clientCoords(event);
      targetScreenCoords = layer.screenFrame;
      e.x -= targetScreenCoords.x;
      e.y -= targetScreenCoords.y;
    }
    return e;
  };

  offsetCoords = function(ev) {
    var e;
    e = Events.touchEvent(ev);
    return coords(e.offsetX, e.offsetY);
  };

  clientCoords = function(ev) {
    var e;
    e = Events.touchEvent(ev);
    return coords(e.clientX, e.clientY);
  };

  coords = function(x, y) {
    return {
      x: x,
      y: y
    };
  };

  screenArgumentError = function() {
    error(null);
    return console.error("Pointer.screen() Error: You must pass event & layer arguments. \n\nExample: layer.on Events.TouchStart,(event,layer) -> Pointer.screen(event, layer)");
  };

  offsetArgumentError = function() {
    error(null);
    return console.error("Pointer.offset() Error: You must pass event & layer arguments. \n\nExample: layer.on Events.TouchStart,(event,layer) -> Pointer.offset(event, layer)");
  };

  return Pointer;

})();


},{}],3:[function(require,module,exports){
var Pointer;

Pointer = require("./Pointer").Pointer;

exports.ripple = function(event, layer) {
  var animation, color, eventCoords, pressFeedback, rippleCircle;
  eventCoords = Pointer.offset(event, layer);
  color = "black";
  animation = {
    curve: "ease-out",
    time: .4
  };
  pressFeedback = new Layer({
    superLayer: this,
    name: "pressFeedback",
    width: layer.width,
    height: layer.height,
    opacity: 0,
    backgroundColor: color
  });
  pressFeedback.states.add({
    pressed: {
      opacity: .04
    }
  });
  pressFeedback.states["switch"]("pressed", animation);
  rippleCircle = new Layer({
    superLayer: this,
    name: "rippleCircle",
    borderRadius: "50%",
    midX: eventCoords.x,
    midY: eventCoords.y,
    opacity: .16,
    backgroundColor: color
  });
  rippleCircle.states.add({
    pressed: {
      scale: layer.width / 60,
      opacity: 0
    }
  });
  rippleCircle.states["switch"]("pressed", animation);
  return Utils.delay(0.3, function() {
    pressFeedback.states.next("default", animation);
    return pressFeedback.on(Events.AnimationEnd, function() {
      rippleCircle.destroy();
      return pressFeedback.destroy();
    });
  });
};


},{"./Pointer":2}],4:[function(require,module,exports){
// import Firebase from 'firebase';

// const fb = {
//   url: 'https://connectprototypes.firebaseio.com/'
// };

// let ref = new Firebase(fb.url);
// ref.on('value', ()=>{
//   console.log(arguments);
// });

'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});
var ref = 'fbObject';

exports['default'] = ref;
module.exports = exports['default'];

},{}],5:[function(require,module,exports){
'use strict';

var _arguments = arguments;

var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj['default'] = obj; return newObj; } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

var _layers = require('./layers');

var layers = _interopRequireWildcard(_layers);

require('./states');

var _connector = require('./connector');

var _connector2 = _interopRequireDefault(_connector);

function scene(state, option) {
  Framer.CurrentContext._layerList.forEach(function (layer) {
    if (layer._states && layer._states._orderedStates.indexOf(state) >= 0) {
      layer.states['switch'](state, option);
    }
  });
}

var earthRollingToggle = true;

function earthRolling(timestamp) {
  var r1 = Math.cos(timestamp / 1000) * 5;
  var r2 = Math.sin(timestamp / 1000) * 5;
  layers.earth.animate({
    properties: {
      rotation: r1
    }
  });
  layers.cloud1.animate({
    properties: {
      rotation: r2
    }
  });
  layers.cloud2.animate({
    properties: {
      rotation: r2,
      x: r2 * 5
    }
  });
  layers.phone.animate({
    properties: {
      rotation: r1 * .3
    }
  });
  if (earthRollingToggle) window.requestAnimationFrame(earthRolling);
}
var earthRollingStart = function earthRollingStart() {
  earthRollingToggle = true;
  window.requestAnimationFrame(earthRolling);
};
var earthRollingStop = function earthRollingStop() {
  earthRollingToggle = false;
  setTimeout(function () {
    [layers.earth, layers.cloud1, layers.cloud2].forEach(function (l) {
      l.animate({
        properties: {
          rotation: 0
        }
      });
    });
  }, 100);
};

var Wave = (function () {
  function Wave(parent) {
    _classCallCheck(this, Wave);

    this.wave1 = new Layer({
      superLayer: parent,
      midX: parent.height / 2,
      midY: parent.height / 2,
      width: parent.width,
      height: parent.height,
      scale: 0,
      backgroundColor: '#00a2f4',
      borderRadius: parent.height
    });
    this.wave2 = new Layer({
      superLayer: parent,
      midX: parent.height / 2,
      midY: parent.height / 2,
      width: parent.width,
      height: parent.height,
      scale: this.wave1.scale * 0.6,
      backgroundColor: '#0091ea',
      borderRadius: parent.height
    });
  }

  _createClass(Wave, [{
    key: 'move',
    value: function move() {
      var _this = this;

      this.wave1.animate({
        properties: {
          scale: 1.1
        },
        time: 5,
        curve: "cubic-bezier(.28,.36,.91,.57)"
      });
      Utils.delay(0.2, function () {
        _this.wave2.animate({
          properties: {
            scale: 1
          },
          time: 5,
          curve: "cubic-bezier(.28,.36,.91,.57)"
        });
        _this.wave2.on(Events.AnimationEnd, function () {
          _this.end();
        });
      });
    }
  }, {
    key: 'end',
    value: function end() {
      this.wave1.destroy();
      this.wave2.destroy();
    }
  }]);

  return Wave;
})();

function waveStart() {
  var wave = new Wave(layers.signalWrapper);
  wave.move();
  Utils.delay(1.4, function () {
    if (waveState) waveStart();
  });
}

function waveStop() {
  waveState = false;
}

var waveState = false;

layers.connectWrapper.on(Events.Click, function () {
  Utils.delay(0.3, function () {
    scene('expand');
  });
  earthRollingStart();
  waveState = true;
  waveStart();
  Utils.delay(0.7, function () {
    scene('connectStart', { time: 0.4, curve: "cubic-bezier(.9,.08,.44,.97)" });
  });
  Utils.delay(1.8, function () {
    scene('findDevices', { time: 0.3, curve: "spring(200, 20, 0)" });
  });
});

layers.close.on(Events.Click, function () {
  scene('default');
  waveStop();
  console.log(_arguments);
});

var android = require('androidRipple');
layers.connectButton.on(Events.Click, android.ripple);

layers.users.subLayers.forEach(function (user) {
  user.on(Events.TouchStart, function (e, layer) {
    layer.animate({
      properties: {
        scale: 1.2
      }
    });
  });
  user.on(Events.TouchEnd, function (e, layer) {
    layers.text.states['switch']('out', { time: 0.1 });
    Utils.delay(0.3, function () {
      layers.text.html = '<h1>Connecting...</h1>';
      layers.text.states['switch']('in', { time: 0.1 });
    });
    layer.animate({
      properties: {
        scale: 1
      }
    });
    user.states['switch']('connectRequest');
    layers.users.subLayers.forEach(function (sub) {
      if (sub !== user) {
        sub.states['switch']('connectRequestHide');
      }
    });
    Utils.delay(0.5, function () {
      scene('connecting');
    });
  });
});

},{"./connector":4,"./layers":6,"./states":7,"androidRipple":3}],6:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
Framer.Device = new Framer.DeviceView();
Framer.Device.setupContext();
Framer.Device.deviceType = "iphone-6-gold";
Framer.Defaults.Animation = { curve: "spring(300,30,0)" };
var color = {
  background: '#f4f4f4',
  connectButton: '#fff',
  connectButtonText: '#0091ea',
  connectBack: '#0091ea',
  signal: '#00a2f4'
};

var background = new BackgroundLayer({
  backgroundColor: color.background
});

var connectButton = new Layer({
  width: 480,
  height: 80,
  backgroundColor: 'transparent',
  force2d: true,
  shadowY: 3,
  shadowBlur: 12,
  shadowColor: "rgba(0,0,0,0.2)",
  borderRadius: 12

});
exports.connectButton = connectButton;
connectButton.center();

var connectWrapper = new Layer({
  superLayer: connectButton,
  width: 480,
  height: 80,
  opacity: 1,
  backgroundColor: color.connectButton
});
exports.connectWrapper = connectWrapper;
connectWrapper.center();

var connectButtonText = new Layer({
  superLayer: connectWrapper,
  width: 250,
  height: 30,
  html: 'Connect',
  backgroundColor: color.connectButton,
  style: {
    'font-size': '30px',
    'color': color.connectButtonText,
    'text-align': 'center',
    'line-height': 1
  }
});
connectButtonText.center();

var connectWrapperBack = new Layer({
  superLayer: connectButton,
  width: 40,
  height: 40,
  backgroundColor: color.connectButtonText,
  opacity: 0,
  borderRadius: 3000
});
exports.connectWrapperBack = connectWrapperBack;
connectWrapperBack.center();

var signal = new Layer({
  superLayer: connectButton,
  midX: Screen.width / 2,
  y: 200,
  // width: Screen.height*1.3,
  // height: Screen.height*1.3,
  width: 900,
  height: 900,
  rotation: 222,
  opacity: 0,
  backgroundColor: 'transparent'
});

exports.signal = signal;
var signalWrapper = new Layer({
  superLayer: signal,
  midX: 0,
  midY: 0,
  width: signal.width,
  height: signal.height,
  scale: 2,
  backgroundColor: 'transparent',
  borderRadius: signal.height
});

exports.signalWrapper = signalWrapper;
var signalLine1 = new Layer({
  superLayer: signal,
  x: -20,
  y: 0,
  rotation: 90,
  width: Screen.height,
  height: 400,
  backgroundColor: color.connectBack,
  originY: 0,
  originX: 0
});
exports.signalLine1 = signalLine1;
var signalLine2 = new Layer({
  superLayer: signal,
  x: 180,
  y: -400,
  rotation: 0,
  width: Screen.height,
  height: 400,
  backgroundColor: color.connectBack,
  originY: 0,
  originX: 0
});

exports.signalLine2 = signalLine2;
var phone = new Layer({
  superLayer: connectButton,
  midX: Screen.width / 2,
  y: Screen.height,
  width: 250,
  height: 426,
  image: './images/device.png',
  originY: 1.2
});

exports.phone = phone;
var earth = new Layer({
  superLayer: connectButton,
  y: Screen.height,
  width: Screen.width,
  height: 466 * 3,
  backgroundColor: 'transparent',
  scale: 1.05
});

exports.earth = earth;
var cloud1 = new Layer({
  superLayer: earth,
  y: 95,
  width: Screen.width,
  height: 295,
  image: './images/clouds.png'
});

exports.cloud1 = cloud1;
var land = new Layer({
  superLayer: earth,
  width: Screen.width,
  height: 466,
  image: './images/earth.png'
});
land.centerX();

var cloud2 = new Layer({
  superLayer: earth,
  y: 120,
  width: Screen.width,
  height: 400,
  image: './images/clouds.png'
});

exports.cloud2 = cloud2;
var close = new Layer({
  superLayer: connectButton,
  x: -39,
  y: -39,
  width: 39,
  height: 39,
  image: './images/close.png',
  opacity: 0
});

exports.close = close;
var text = new Layer({
  y: 250,
  width: 380,
  height: 48,
  html: '<h1>Waiting for connect..</h1>',
  backgroundColor: 'transparent',
  opacity: 0
});
exports.text = text;
text.centerX();

var users = new Layer({
  y: 300,
  width: Screen.width,
  height: 500,
  backgroundColor: 'transparent',
  opacity: 0
});

exports.users = users;
var user1 = new Layer({
  superLayer: users,
  x: 60,
  y: 112,
  width: 105,
  height: 200,
  backgroundColor: 'transparent',
  scale: 0
});
exports.user1 = user1;
var user1picture = new Layer({
  superLayer: user1,
  width: 105,
  height: 105,
  image: './images/user1.png'
});
user1picture.centerX();
var user1name = new Layer({
  superLayer: user1,
  y: 124,
  width: 130,
  height: 65,
  image: './images/user1name.png'
});

var user2 = new Layer({
  superLayer: users,
  x: 318,
  y: 256,
  width: 105,
  height: 200,
  backgroundColor: 'transparent',
  scale: 0
});
exports.user2 = user2;
var user2picture = new Layer({
  superLayer: user2,
  width: 105,
  height: 105,
  image: './images/user1.png'
});
user2picture.centerX();
var user2name = new Layer({
  superLayer: user2,
  y: 124,
  width: 130,
  height: 65,
  image: './images/user1name.png'
});

},{}],7:[function(require,module,exports){
// import {earth, connectButton, connectWrapper, connectWrapperBack} from './layers';
'use strict';

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj['default'] = obj; return newObj; } }

var _layers = require('./layers');

var layers = _interopRequireWildcard(_layers);

layers.earth.states.add('connectStart', {
  y: Screen.height - 420
});
layers.phone.states.add('connectStart', {
  y: Screen.height - 460
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
  midX: Screen.width / 2,
  midY: Screen.height / 2,
  width: Screen.width * 2.1,
  height: Screen.width * 2.1
});
layers.close.states.add('expand', {
  x: 72,
  y: 72,
  opacity: 1
});

layers.users.subLayers.forEach(function (layer) {
  layer.states.add('findDevices', {
    scale: 1
  });
});

layers.user1.states.add('connectRequest', {
  midX: Screen.width / 2,
  y: 50
});
layers.user1.states.add('connectRequestHide', {
  y: 300,
  opacity: 0
});
layers.user2.states.add('connectRequest', {
  midX: Screen.width / 2,
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
  rotation: 48
});

layers.signalLine2.states.add('connecting', {
  rotation: 43.5
});

},{"./layers":6}]},{},[1])
//# sourceMappingURL=data:application/json;charset:utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi4uLy4uL25vZGVfbW9kdWxlcy9mcmFtZXItY2xpL25vZGVfbW9kdWxlcy9icm93c2VyaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCJjOi9wcm9qZWN0cy90b21teWJlYmUuZ2l0aHViLmlvL3Byb3RvdHlwZXMvMDItY29ubmVjdC1ob3RzcG90L2luZGV4LmpzIiwiYzpcXHByb2plY3RzXFx0b21teWJlYmUuZ2l0aHViLmlvXFxwcm90b3R5cGVzXFwwMi1jb25uZWN0LWhvdHNwb3RcXG1vZHVsZXNcXFBvaW50ZXIuY29mZmVlIiwiYzpcXHByb2plY3RzXFx0b21teWJlYmUuZ2l0aHViLmlvXFxwcm90b3R5cGVzXFwwMi1jb25uZWN0LWhvdHNwb3RcXG1vZHVsZXNcXGFuZHJvaWRSaXBwbGUuY29mZmVlIiwiYzovcHJvamVjdHMvdG9tbXliZWJlLmdpdGh1Yi5pby9wcm90b3R5cGVzLzAyLWNvbm5lY3QtaG90c3BvdC9zY3JpcHRzL2Nvbm5lY3Rvci5qcyIsImM6L3Byb2plY3RzL3RvbW15YmViZS5naXRodWIuaW8vcHJvdG90eXBlcy8wMi1jb25uZWN0LWhvdHNwb3Qvc2NyaXB0cy9jb250cm9sbGVyLmpzIiwiYzovcHJvamVjdHMvdG9tbXliZWJlLmdpdGh1Yi5pby9wcm90b3R5cGVzLzAyLWNvbm5lY3QtaG90c3BvdC9zY3JpcHRzL2xheWVycy5qcyIsImM6L3Byb2plY3RzL3RvbW15YmViZS5naXRodWIuaW8vcHJvdG90eXBlcy8wMi1jb25uZWN0LWhvdHNwb3Qvc2NyaXB0cy9zdGF0ZXMuanMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUE7Ozs7Ozs7Ozs7O1FDUU8sc0JBQXNCOzs7QUNZdkIsT0FBTyxDQUFDO0FBS1YsTUFBQTs7OztFQUFBLE9BQUMsQ0FBQSxNQUFELEdBQVUsU0FBQyxLQUFELEVBQVEsS0FBUjtBQUNOLFFBQUE7SUFBQSxJQUFBLENBQUEsQ0FBNkIsZUFBQSxJQUFXLGVBQXhDLENBQUE7TUFBQSxtQkFBQSxDQUFBLEVBQUE7O0lBQ0EsQ0FBQSxHQUFJLFlBQUEsQ0FBYSxLQUFiO0lBQ0osSUFBRyxDQUFDLENBQUMsQ0FBRixJQUFRLENBQUMsQ0FBQyxDQUFiO01BRUksWUFBQSxHQUFlLEtBQUssQ0FBQztNQUNyQixDQUFDLENBQUMsQ0FBRixJQUFPLFlBQVksQ0FBQztNQUNwQixDQUFDLENBQUMsQ0FBRixJQUFPLFlBQVksQ0FBQyxFQUp4QjtLQUFBLE1BQUE7TUFPSSxDQUFBLEdBQUksWUFBQSxDQUFhLEtBQWIsRUFQUjs7QUFRQSxXQUFPO0VBWEQ7O0VBYVYsT0FBQyxDQUFBLE1BQUQsR0FBVSxTQUFDLEtBQUQsRUFBUSxLQUFSO0FBQ04sUUFBQTtJQUFBLElBQUEsQ0FBQSxDQUE2QixlQUFBLElBQVcsZUFBeEMsQ0FBQTtNQUFBLG1CQUFBLENBQUEsRUFBQTs7SUFDQSxDQUFBLEdBQUksWUFBQSxDQUFhLEtBQWI7SUFDSixJQUFBLENBQUEsQ0FBTyxhQUFBLElBQVMsYUFBaEIsQ0FBQTtNQUVJLENBQUEsR0FBSSxZQUFBLENBQWEsS0FBYjtNQUNKLGtCQUFBLEdBQXFCLEtBQUssQ0FBQztNQUMzQixDQUFDLENBQUMsQ0FBRixJQUFPLGtCQUFrQixDQUFDO01BQzFCLENBQUMsQ0FBQyxDQUFGLElBQU8sa0JBQWtCLENBQUMsRUFMOUI7O0FBTUEsV0FBTztFQVREOztFQWNWLFlBQUEsR0FBZSxTQUFDLEVBQUQ7QUFBUyxRQUFBO0lBQUEsQ0FBQSxHQUFJLE1BQU0sQ0FBQyxVQUFQLENBQWtCLEVBQWxCO0FBQXNCLFdBQU8sTUFBQSxDQUFPLENBQUMsQ0FBQyxPQUFULEVBQWtCLENBQUMsQ0FBQyxPQUFwQjtFQUExQzs7RUFDZixZQUFBLEdBQWUsU0FBQyxFQUFEO0FBQVMsUUFBQTtJQUFBLENBQUEsR0FBSSxNQUFNLENBQUMsVUFBUCxDQUFrQixFQUFsQjtBQUFzQixXQUFPLE1BQUEsQ0FBTyxDQUFDLENBQUMsT0FBVCxFQUFrQixDQUFDLENBQUMsT0FBcEI7RUFBMUM7O0VBQ2YsTUFBQSxHQUFlLFNBQUMsQ0FBRCxFQUFHLENBQUg7QUFBUyxXQUFPO01BQUEsQ0FBQSxFQUFFLENBQUY7TUFBSyxDQUFBLEVBQUUsQ0FBUDs7RUFBaEI7O0VBS2YsbUJBQUEsR0FBc0IsU0FBQTtJQUNsQixLQUFBLENBQU0sSUFBTjtXQUNBLE9BQU8sQ0FBQyxLQUFSLENBQWMsc0pBQWQ7RUFGa0I7O0VBTXRCLG1CQUFBLEdBQXNCLFNBQUE7SUFDbEIsS0FBQSxDQUFNLElBQU47V0FDQSxPQUFPLENBQUMsS0FBUixDQUFjLHNKQUFkO0VBRmtCOzs7Ozs7OztBQ2xEMUIsSUFBQTs7QUFBQyxVQUFXLE9BQUEsQ0FBUSxXQUFSLEVBQVg7O0FBR0QsT0FBTyxDQUFDLE1BQVIsR0FBaUIsU0FBQyxLQUFELEVBQVEsS0FBUjtBQUNiLE1BQUE7RUFBQSxXQUFBLEdBQWMsT0FBTyxDQUFDLE1BQVIsQ0FBZSxLQUFmLEVBQXNCLEtBQXRCO0VBR2QsS0FBQSxHQUFRO0VBQ1IsU0FBQSxHQUFZO0lBQUEsS0FBQSxFQUFPLFVBQVA7SUFBbUIsSUFBQSxFQUFNLEVBQXpCOztFQUdaLGFBQUEsR0FBb0IsSUFBQSxLQUFBLENBQ2hCO0lBQUEsVUFBQSxFQUFZLElBQVo7SUFDQSxJQUFBLEVBQU0sZUFETjtJQUVBLEtBQUEsRUFBTyxLQUFLLENBQUMsS0FGYjtJQUdBLE1BQUEsRUFBUSxLQUFLLENBQUMsTUFIZDtJQUlBLE9BQUEsRUFBUyxDQUpUO0lBS0EsZUFBQSxFQUFpQixLQUxqQjtHQURnQjtFQU9wQixhQUFhLENBQUMsTUFBTSxDQUFDLEdBQXJCLENBQ0k7SUFBQSxPQUFBLEVBQVM7TUFBQSxPQUFBLEVBQVMsR0FBVDtLQUFUO0dBREo7RUFFQSxhQUFhLENBQUMsTUFBTSxDQUFDLFFBQUQsQ0FBcEIsQ0FBNEIsU0FBNUIsRUFBdUMsU0FBdkM7RUFFQSxZQUFBLEdBQW1CLElBQUEsS0FBQSxDQUNmO0lBQUEsVUFBQSxFQUFZLElBQVo7SUFDQSxJQUFBLEVBQU0sY0FETjtJQUVBLFlBQUEsRUFBYyxLQUZkO0lBR0EsSUFBQSxFQUFNLFdBQVcsQ0FBQyxDQUhsQjtJQUlBLElBQUEsRUFBTSxXQUFXLENBQUMsQ0FKbEI7SUFLQSxPQUFBLEVBQVMsR0FMVDtJQU1BLGVBQUEsRUFBaUIsS0FOakI7R0FEZTtFQVFuQixZQUFZLENBQUMsTUFBTSxDQUFDLEdBQXBCLENBQ0k7SUFBQSxPQUFBLEVBQVM7TUFBQSxLQUFBLEVBQU8sS0FBSyxDQUFDLEtBQU4sR0FBYyxFQUFyQjtNQUF5QixPQUFBLEVBQVMsQ0FBbEM7S0FBVDtHQURKO0VBRUEsWUFBWSxDQUFDLE1BQU0sQ0FBQyxRQUFELENBQW5CLENBQTJCLFNBQTNCLEVBQXNDLFNBQXRDO1NBR0EsS0FBSyxDQUFDLEtBQU4sQ0FBWSxHQUFaLEVBQWlCLFNBQUE7SUFDYixhQUFhLENBQUMsTUFBTSxDQUFDLElBQXJCLENBQTBCLFNBQTFCLEVBQXFDLFNBQXJDO1dBQ0EsYUFBYSxDQUFDLEVBQWQsQ0FBaUIsTUFBTSxDQUFDLFlBQXhCLEVBQXNDLFNBQUE7TUFDbEMsWUFBWSxDQUFDLE9BQWIsQ0FBQTthQUNBLGFBQWEsQ0FBQyxPQUFkLENBQUE7SUFGa0MsQ0FBdEM7RUFGYSxDQUFqQjtBQWhDYTs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7QUNQakIsSUFBSSxHQUFHLEdBQUcsVUFBVSxDQUFDOztxQkFFTixHQUFHOzs7Ozs7Ozs7Ozs7Ozs7O3NCQ2JNLFVBQVU7O0lBQXRCLE1BQU07O1FBQ1gsVUFBVTs7eUJBQ0ssYUFBYTs7OztBQUVuQyxTQUFTLEtBQUssQ0FBRSxLQUFLLEVBQUUsTUFBTSxFQUFFO0FBQzdCLFFBQU0sQ0FBQyxjQUFjLENBQUMsVUFBVSxDQUFDLE9BQU8sQ0FBQyxVQUFTLEtBQUssRUFBQztBQUN0RCxRQUFHLEtBQUssQ0FBQyxPQUFPLElBQUksS0FBSyxDQUFDLE9BQU8sQ0FBQyxjQUFjLENBQUMsT0FBTyxDQUFDLEtBQUssQ0FBQyxJQUFJLENBQUMsRUFBQztBQUNuRSxXQUFLLENBQUMsTUFBTSxVQUFPLENBQUMsS0FBSyxFQUFFLE1BQU0sQ0FBQyxDQUFDO0tBQ3BDO0dBQ0YsQ0FBQyxDQUFDO0NBQ0o7O0FBRUQsSUFBSSxrQkFBa0IsR0FBRyxJQUFJLENBQUM7O0FBRTlCLFNBQVMsWUFBWSxDQUFDLFNBQVMsRUFBRTtBQUMvQixNQUFJLEVBQUUsR0FBRyxJQUFJLENBQUMsR0FBRyxDQUFDLFNBQVMsR0FBQyxJQUFJLENBQUMsR0FBQyxDQUFDLENBQUM7QUFDcEMsTUFBSSxFQUFFLEdBQUcsSUFBSSxDQUFDLEdBQUcsQ0FBQyxTQUFTLEdBQUMsSUFBSSxDQUFDLEdBQUMsQ0FBQyxDQUFDO0FBQ3BDLFFBQU0sQ0FBQyxLQUFLLENBQUMsT0FBTyxDQUFDO0FBQ25CLGNBQVUsRUFBRTtBQUNWLGNBQVEsRUFBRSxFQUFFO0tBQ2I7R0FDRixDQUFDLENBQUM7QUFDSCxRQUFNLENBQUMsTUFBTSxDQUFDLE9BQU8sQ0FBQztBQUNwQixjQUFVLEVBQUU7QUFDVixjQUFRLEVBQUUsRUFBRTtLQUNiO0dBQ0YsQ0FBQyxDQUFDO0FBQ0gsUUFBTSxDQUFDLE1BQU0sQ0FBQyxPQUFPLENBQUM7QUFDcEIsY0FBVSxFQUFFO0FBQ1YsY0FBUSxFQUFFLEVBQUU7QUFDWixPQUFDLEVBQUUsRUFBRSxHQUFDLENBQUM7S0FDUjtHQUNGLENBQUMsQ0FBQztBQUNILFFBQU0sQ0FBQyxLQUFLLENBQUMsT0FBTyxDQUFDO0FBQ25CLGNBQVUsRUFBRTtBQUNWLGNBQVEsRUFBRSxFQUFFLEdBQUMsRUFBRTtLQUNoQjtHQUNGLENBQUMsQ0FBQztBQUNILE1BQUcsa0JBQWtCLEVBQUUsTUFBTSxDQUFDLHFCQUFxQixDQUFDLFlBQVksQ0FBQyxDQUFDO0NBQ25FO0FBQ0QsSUFBSSxpQkFBaUIsR0FBRyxTQUFwQixpQkFBaUIsR0FBUTtBQUMzQixvQkFBa0IsR0FBRyxJQUFJLENBQUM7QUFDMUIsUUFBTSxDQUFDLHFCQUFxQixDQUFDLFlBQVksQ0FBQyxDQUFDO0NBQzVDLENBQUE7QUFDRCxJQUFJLGdCQUFnQixHQUFHLFNBQW5CLGdCQUFnQixHQUFRO0FBQzFCLG9CQUFrQixHQUFHLEtBQUssQ0FBQztBQUMzQixZQUFVLENBQUMsWUFBVTtBQUNuQixLQUFDLE1BQU0sQ0FBQyxLQUFLLEVBQUUsTUFBTSxDQUFDLE1BQU0sRUFBRSxNQUFNLENBQUMsTUFBTSxDQUFDLENBQUMsT0FBTyxDQUFDLFVBQVMsQ0FBQyxFQUFDO0FBQzlELE9BQUMsQ0FBQyxPQUFPLENBQUM7QUFDUixrQkFBVSxFQUFFO0FBQ1Ysa0JBQVEsRUFBRSxDQUFDO1NBQ1o7T0FDRixDQUFDLENBQUM7S0FDSixDQUFDLENBQUM7R0FDSixFQUFFLEdBQUcsQ0FBQyxDQUFDO0NBQ1QsQ0FBQTs7SUFHSyxJQUFJO0FBQ0csV0FEUCxJQUFJLENBQ0ksTUFBTSxFQUFFOzBCQURoQixJQUFJOztBQUVOLFFBQUksQ0FBQyxLQUFLLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDckIsZ0JBQVUsRUFBRSxNQUFNO0FBQ2xCLFVBQUksRUFBRSxNQUFNLENBQUMsTUFBTSxHQUFDLENBQUM7QUFDckIsVUFBSSxFQUFFLE1BQU0sQ0FBQyxNQUFNLEdBQUMsQ0FBQztBQUNyQixXQUFLLEVBQUUsTUFBTSxDQUFDLEtBQUs7QUFDbkIsWUFBTSxFQUFFLE1BQU0sQ0FBQyxNQUFNO0FBQ3JCLFdBQUssRUFBRSxDQUFDO0FBQ1IscUJBQWUsRUFBRSxTQUFTO0FBQzFCLGtCQUFZLEVBQUUsTUFBTSxDQUFDLE1BQU07S0FDNUIsQ0FBQyxDQUFDO0FBQ0gsUUFBSSxDQUFDLEtBQUssR0FBRyxJQUFJLEtBQUssQ0FBQztBQUNyQixnQkFBVSxFQUFFLE1BQU07QUFDbEIsVUFBSSxFQUFFLE1BQU0sQ0FBQyxNQUFNLEdBQUMsQ0FBQztBQUNyQixVQUFJLEVBQUUsTUFBTSxDQUFDLE1BQU0sR0FBQyxDQUFDO0FBQ3JCLFdBQUssRUFBRSxNQUFNLENBQUMsS0FBSztBQUNuQixZQUFNLEVBQUUsTUFBTSxDQUFDLE1BQU07QUFDckIsV0FBSyxFQUFFLElBQUksQ0FBQyxLQUFLLENBQUMsS0FBSyxHQUFDLEdBQUc7QUFDM0IscUJBQWUsRUFBRSxTQUFTO0FBQzFCLGtCQUFZLEVBQUUsTUFBTSxDQUFDLE1BQU07S0FDNUIsQ0FBQyxDQUFDO0dBQ0o7O2VBdEJHLElBQUk7O1dBdUJKLGdCQUFFOzs7QUFDSixVQUFJLENBQUMsS0FBSyxDQUFDLE9BQU8sQ0FBQztBQUNqQixrQkFBVSxFQUFFO0FBQ1YsZUFBSyxFQUFFLEdBQUc7U0FDWDtBQUNELFlBQUksRUFBRSxDQUFDO0FBQ1AsYUFBSyxFQUFFLCtCQUErQjtPQUN2QyxDQUFDLENBQUM7QUFDSCxXQUFLLENBQUMsS0FBSyxDQUFDLEdBQUcsRUFBRSxZQUFJO0FBQ25CLGNBQUssS0FBSyxDQUFDLE9BQU8sQ0FBQztBQUNqQixvQkFBVSxFQUFFO0FBQ1YsaUJBQUssRUFBRSxDQUFDO1dBQ1Q7QUFDRCxjQUFJLEVBQUUsQ0FBQztBQUNQLGVBQUssRUFBRSwrQkFBK0I7U0FDdkMsQ0FBQyxDQUFDO0FBQ0gsY0FBSyxLQUFLLENBQUMsRUFBRSxDQUFDLE1BQU0sQ0FBQyxZQUFZLEVBQUUsWUFBSTtBQUNyQyxnQkFBSyxHQUFHLEVBQUUsQ0FBQztTQUNaLENBQUMsQ0FBQztPQUNKLENBQUMsQ0FBQztLQUNKOzs7V0FDRSxlQUFFO0FBQ0gsVUFBSSxDQUFDLEtBQUssQ0FBQyxPQUFPLEVBQUUsQ0FBQztBQUNyQixVQUFJLENBQUMsS0FBSyxDQUFDLE9BQU8sRUFBRSxDQUFDO0tBQ3RCOzs7U0EvQ0csSUFBSTs7O0FBa0RWLFNBQVMsU0FBUyxHQUFFO0FBQ2xCLE1BQUksSUFBSSxHQUFHLElBQUksSUFBSSxDQUFDLE1BQU0sQ0FBQyxhQUFhLENBQUMsQ0FBQztBQUMxQyxNQUFJLENBQUMsSUFBSSxFQUFFLENBQUM7QUFDWixPQUFLLENBQUMsS0FBSyxDQUFDLEdBQUcsRUFBRSxZQUFJO0FBQ25CLFFBQUcsU0FBUyxFQUFFLFNBQVMsRUFBRSxDQUFDO0dBQzNCLENBQUMsQ0FBQztDQUNKOztBQUVELFNBQVMsUUFBUSxHQUFFO0FBQ2pCLFdBQVMsR0FBRyxLQUFLLENBQUM7Q0FDbkI7O0FBRUQsSUFBSSxTQUFTLEdBQUcsS0FBSyxDQUFDOztBQUV0QixNQUFNLENBQUMsY0FBYyxDQUFDLEVBQUUsQ0FBQyxNQUFNLENBQUMsS0FBSyxFQUFFLFlBQVU7QUFDL0MsT0FBSyxDQUFDLEtBQUssQ0FBQyxHQUFHLEVBQUUsWUFBVTtBQUN6QixTQUFLLENBQUMsUUFBUSxDQUFDLENBQUM7R0FDakIsQ0FBQyxDQUFDO0FBQ0gsbUJBQWlCLEVBQUUsQ0FBQztBQUNwQixXQUFTLEdBQUcsSUFBSSxDQUFDO0FBQ2pCLFdBQVMsRUFBRSxDQUFDO0FBQ1osT0FBSyxDQUFDLEtBQUssQ0FBQyxHQUFHLEVBQUUsWUFBVTtBQUN6QixTQUFLLENBQUMsY0FBYyxFQUFFLEVBQUUsSUFBSSxFQUFFLEdBQUcsRUFBRSxLQUFLLEVBQUUsOEJBQThCLEVBQUUsQ0FBQyxDQUFDO0dBQzdFLENBQUMsQ0FBQztBQUNILE9BQUssQ0FBQyxLQUFLLENBQUMsR0FBRyxFQUFFLFlBQVU7QUFDekIsU0FBSyxDQUFDLGFBQWEsRUFBRSxFQUFFLElBQUksRUFBRSxHQUFHLEVBQUUsS0FBSyxFQUFFLG9CQUFvQixFQUFFLENBQUMsQ0FBQztHQUNsRSxDQUFDLENBQUM7Q0FDSixDQUFDLENBQUM7O0FBRUgsTUFBTSxDQUFDLEtBQUssQ0FBQyxFQUFFLENBQUMsTUFBTSxDQUFDLEtBQUssRUFBRSxZQUFJO0FBQ2hDLE9BQUssQ0FBQyxTQUFTLENBQUMsQ0FBQztBQUNqQixVQUFRLEVBQUUsQ0FBQztBQUNYLFNBQU8sQ0FBQyxHQUFHLFlBQVcsQ0FBQztDQUN4QixDQUFDLENBQUM7O0FBRUgsSUFBSSxPQUFPLEdBQUcsT0FBTyxDQUFDLGVBQWUsQ0FBQyxDQUFDO0FBQ3ZDLE1BQU0sQ0FBQyxhQUFhLENBQUMsRUFBRSxDQUFDLE1BQU0sQ0FBQyxLQUFLLEVBQUUsT0FBTyxDQUFDLE1BQU0sQ0FBQyxDQUFDOztBQUV0RCxNQUFNLENBQUMsS0FBSyxDQUFDLFNBQVMsQ0FBQyxPQUFPLENBQUMsVUFBUyxJQUFJLEVBQUM7QUFDM0MsTUFBSSxDQUFDLEVBQUUsQ0FBQyxNQUFNLENBQUMsVUFBVSxFQUFFLFVBQVMsQ0FBQyxFQUFFLEtBQUssRUFBQztBQUMzQyxTQUFLLENBQUMsT0FBTyxDQUFDO0FBQ1osZ0JBQVUsRUFBRTtBQUNWLGFBQUssRUFBRSxHQUFHO09BQ1g7S0FDRixDQUFDLENBQUE7R0FDSCxDQUFDLENBQUM7QUFDSCxNQUFJLENBQUMsRUFBRSxDQUFDLE1BQU0sQ0FBQyxRQUFRLEVBQUUsVUFBUyxDQUFDLEVBQUUsS0FBSyxFQUFDO0FBQ3pDLFVBQU0sQ0FBQyxJQUFJLENBQUMsTUFBTSxVQUFPLENBQUMsS0FBSyxFQUFFLEVBQUUsSUFBSSxFQUFFLEdBQUcsRUFBRSxDQUFDLENBQUM7QUFDaEQsU0FBSyxDQUFDLEtBQUssQ0FBQyxHQUFHLEVBQUUsWUFBSTtBQUNuQixZQUFNLENBQUMsSUFBSSxDQUFDLElBQUksR0FBRyx3QkFBd0IsQ0FBQTtBQUMzQyxZQUFNLENBQUMsSUFBSSxDQUFDLE1BQU0sVUFBTyxDQUFDLElBQUksRUFBRSxFQUFFLElBQUksRUFBRSxHQUFHLEVBQUUsQ0FBQyxDQUFDO0tBQ2hELENBQUMsQ0FBQztBQUNILFNBQUssQ0FBQyxPQUFPLENBQUM7QUFDWixnQkFBVSxFQUFFO0FBQ1YsYUFBSyxFQUFFLENBQUM7T0FDVDtLQUNGLENBQUMsQ0FBQztBQUNILFFBQUksQ0FBQyxNQUFNLFVBQU8sQ0FBQyxnQkFBZ0IsQ0FBQyxDQUFDO0FBQ3JDLFVBQU0sQ0FBQyxLQUFLLENBQUMsU0FBUyxDQUFDLE9BQU8sQ0FBQyxVQUFDLEdBQUcsRUFBRztBQUNwQyxVQUFHLEdBQUcsS0FBSyxJQUFJLEVBQUM7QUFDZCxXQUFHLENBQUMsTUFBTSxVQUFPLENBQUMsb0JBQW9CLENBQUMsQ0FBQztPQUN6QztLQUNGLENBQUMsQ0FBQztBQUNILFNBQUssQ0FBQyxLQUFLLENBQUMsR0FBRyxFQUFFLFlBQUk7QUFDbkIsV0FBSyxDQUFDLFlBQVksQ0FBQyxDQUFDO0tBQ3JCLENBQUMsQ0FBQztHQUNKLENBQUMsQ0FBQztDQUNKLENBQUMsQ0FBQzs7Ozs7Ozs7QUMvS0gsTUFBTSxDQUFDLE1BQU0sR0FBRyxJQUFJLE1BQU0sQ0FBQyxVQUFVLEVBQUUsQ0FBQztBQUN4QyxNQUFNLENBQUMsTUFBTSxDQUFDLFlBQVksRUFBRSxDQUFDO0FBQzdCLE1BQU0sQ0FBQyxNQUFNLENBQUMsVUFBVSxHQUFHLGVBQWUsQ0FBQztBQUMzQyxNQUFNLENBQUMsUUFBUSxDQUFDLFNBQVMsR0FBRyxFQUFFLEtBQUssRUFBRSxrQkFBa0IsRUFBRSxDQUFDO0FBQzFELElBQU0sS0FBSyxHQUFHO0FBQ1osWUFBVSxFQUFFLFNBQVM7QUFDckIsZUFBYSxFQUFFLE1BQU07QUFDckIsbUJBQWlCLEVBQUUsU0FBUztBQUM1QixhQUFXLEVBQUUsU0FBUztBQUN0QixRQUFNLEVBQUUsU0FBUztDQUNsQixDQUFDOztBQUVGLElBQUksVUFBVSxHQUFHLElBQUksZUFBZSxDQUFDO0FBQ25DLGlCQUFlLEVBQUUsS0FBSyxDQUFDLFVBQVU7Q0FDbEMsQ0FBQyxDQUFDOztBQUVJLElBQUksYUFBYSxHQUFHLElBQUksS0FBSyxDQUFDO0FBQ25DLE9BQUssRUFBRSxHQUFHO0FBQ1YsUUFBTSxFQUFFLEVBQUU7QUFDVixpQkFBZSxFQUFFLGFBQWE7QUFDOUIsU0FBTyxFQUFFLElBQUk7QUFDYixTQUFPLEVBQUUsQ0FBQztBQUNWLFlBQVUsRUFBRSxFQUFFO0FBQ2QsYUFBVyxFQUFFLGlCQUFpQjtBQUM5QixjQUFZLEVBQUUsRUFBRTs7Q0FFakIsQ0FBQyxDQUFDOztBQUNILGFBQWEsQ0FBQyxNQUFNLEVBQUUsQ0FBQzs7QUFFaEIsSUFBSSxjQUFjLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDcEMsWUFBVSxFQUFFLGFBQWE7QUFDekIsT0FBSyxFQUFFLEdBQUc7QUFDVixRQUFNLEVBQUUsRUFBRTtBQUNWLFNBQU8sRUFBRSxDQUFDO0FBQ1YsaUJBQWUsRUFBRSxLQUFLLENBQUMsYUFBYTtDQUNyQyxDQUFDLENBQUM7O0FBQ0gsY0FBYyxDQUFDLE1BQU0sRUFBRSxDQUFDOztBQUV4QixJQUFJLGlCQUFpQixHQUFHLElBQUksS0FBSyxDQUFDO0FBQ2hDLFlBQVUsRUFBRSxjQUFjO0FBQzFCLE9BQUssRUFBRSxHQUFHO0FBQ1YsUUFBTSxFQUFFLEVBQUU7QUFDVixNQUFJLEVBQUUsU0FBUztBQUNmLGlCQUFlLEVBQUUsS0FBSyxDQUFDLGFBQWE7QUFDcEMsT0FBSyxFQUFFO0FBQ0wsZUFBVyxFQUFFLE1BQU07QUFDbkIsV0FBTyxFQUFFLEtBQUssQ0FBQyxpQkFBaUI7QUFDaEMsZ0JBQVksRUFBRSxRQUFRO0FBQ3RCLGlCQUFhLEVBQUUsQ0FBQztHQUNqQjtDQUNGLENBQUMsQ0FBQztBQUNILGlCQUFpQixDQUFDLE1BQU0sRUFBRSxDQUFDOztBQUVwQixJQUFJLGtCQUFrQixHQUFHLElBQUksS0FBSyxDQUFDO0FBQ3hDLFlBQVUsRUFBRSxhQUFhO0FBQ3pCLE9BQUssRUFBRSxFQUFFO0FBQ1QsUUFBTSxFQUFFLEVBQUU7QUFDVixpQkFBZSxFQUFFLEtBQUssQ0FBQyxpQkFBaUI7QUFDeEMsU0FBTyxFQUFFLENBQUM7QUFDVixjQUFZLEVBQUUsSUFBSTtDQUNuQixDQUFDLENBQUM7O0FBQ0gsa0JBQWtCLENBQUMsTUFBTSxFQUFFLENBQUM7O0FBRXJCLElBQUksTUFBTSxHQUFHLElBQUksS0FBSyxDQUFDO0FBQzVCLFlBQVUsRUFBRSxhQUFhO0FBQ3pCLE1BQUksRUFBRSxNQUFNLENBQUMsS0FBSyxHQUFDLENBQUM7QUFDcEIsR0FBQyxFQUFFLEdBQUc7OztBQUdOLE9BQUssRUFBRSxHQUFHO0FBQ1YsUUFBTSxFQUFFLEdBQUc7QUFDWCxVQUFRLEVBQUUsR0FBRztBQUNiLFNBQU8sRUFBRSxDQUFDO0FBQ1YsaUJBQWUsRUFBRSxhQUFhO0NBQy9CLENBQUMsQ0FBQzs7O0FBRUksSUFBSSxhQUFhLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDbkMsWUFBVSxFQUFFLE1BQU07QUFDbEIsTUFBSSxFQUFFLENBQUM7QUFDUCxNQUFJLEVBQUUsQ0FBQztBQUNQLE9BQUssRUFBRSxNQUFNLENBQUMsS0FBSztBQUNuQixRQUFNLEVBQUUsTUFBTSxDQUFDLE1BQU07QUFDckIsT0FBSyxFQUFFLENBQUM7QUFDUixpQkFBZSxFQUFFLGFBQWE7QUFDOUIsY0FBWSxFQUFFLE1BQU0sQ0FBQyxNQUFNO0NBQzVCLENBQUMsQ0FBQzs7O0FBRUksSUFBSSxXQUFXLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDakMsWUFBVSxFQUFFLE1BQU07QUFDbEIsR0FBQyxFQUFFLENBQUMsRUFBRTtBQUNOLEdBQUMsRUFBRSxDQUFDO0FBQ0osVUFBUSxFQUFFLEVBQUU7QUFDWixPQUFLLEVBQUUsTUFBTSxDQUFDLE1BQU07QUFDcEIsUUFBTSxFQUFFLEdBQUc7QUFDWCxpQkFBZSxFQUFFLEtBQUssQ0FBQyxXQUFXO0FBQ2xDLFNBQU8sRUFBRSxDQUFDO0FBQ1YsU0FBTyxFQUFFLENBQUM7Q0FDWCxDQUFDLENBQUM7O0FBQ0ksSUFBSSxXQUFXLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDakMsWUFBVSxFQUFFLE1BQU07QUFDbEIsR0FBQyxFQUFFLEdBQUc7QUFDTixHQUFDLEVBQUUsQ0FBQyxHQUFHO0FBQ1AsVUFBUSxFQUFFLENBQUM7QUFDWCxPQUFLLEVBQUUsTUFBTSxDQUFDLE1BQU07QUFDcEIsUUFBTSxFQUFFLEdBQUc7QUFDWCxpQkFBZSxFQUFFLEtBQUssQ0FBQyxXQUFXO0FBQ2xDLFNBQU8sRUFBRSxDQUFDO0FBQ1YsU0FBTyxFQUFFLENBQUM7Q0FDWCxDQUFDLENBQUM7OztBQUVJLElBQUksS0FBSyxHQUFHLElBQUksS0FBSyxDQUFDO0FBQzNCLFlBQVUsRUFBRSxhQUFhO0FBQ3pCLE1BQUksRUFBRSxNQUFNLENBQUMsS0FBSyxHQUFDLENBQUM7QUFDcEIsR0FBQyxFQUFFLE1BQU0sQ0FBQyxNQUFNO0FBQ2hCLE9BQUssRUFBRSxHQUFHO0FBQ1YsUUFBTSxFQUFFLEdBQUc7QUFDWCxPQUFLLEVBQUUscUJBQXFCO0FBQzVCLFNBQU8sRUFBRSxHQUFHO0NBQ2IsQ0FBQyxDQUFDOzs7QUFFSSxJQUFJLEtBQUssR0FBRyxJQUFJLEtBQUssQ0FBQztBQUMzQixZQUFVLEVBQUUsYUFBYTtBQUN6QixHQUFDLEVBQUUsTUFBTSxDQUFDLE1BQU07QUFDaEIsT0FBSyxFQUFFLE1BQU0sQ0FBQyxLQUFLO0FBQ25CLFFBQU0sRUFBRSxHQUFHLEdBQUMsQ0FBQztBQUNiLGlCQUFlLEVBQUUsYUFBYTtBQUM5QixPQUFLLEVBQUUsSUFBSTtDQUNaLENBQUMsQ0FBQzs7O0FBRUksSUFBSSxNQUFNLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDNUIsWUFBVSxFQUFFLEtBQUs7QUFDakIsR0FBQyxFQUFFLEVBQUU7QUFDTCxPQUFLLEVBQUUsTUFBTSxDQUFDLEtBQUs7QUFDbkIsUUFBTSxFQUFFLEdBQUc7QUFDWCxPQUFLLEVBQUUscUJBQXFCO0NBQzdCLENBQUMsQ0FBQzs7O0FBRUgsSUFBSSxJQUFJLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDbkIsWUFBVSxFQUFFLEtBQUs7QUFDakIsT0FBSyxFQUFFLE1BQU0sQ0FBQyxLQUFLO0FBQ25CLFFBQU0sRUFBRSxHQUFHO0FBQ1gsT0FBSyxFQUFFLG9CQUFvQjtDQUM1QixDQUFDLENBQUM7QUFDSCxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7O0FBRVIsSUFBSSxNQUFNLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDNUIsWUFBVSxFQUFFLEtBQUs7QUFDakIsR0FBQyxFQUFFLEdBQUc7QUFDTixPQUFLLEVBQUUsTUFBTSxDQUFDLEtBQUs7QUFDbkIsUUFBTSxFQUFFLEdBQUc7QUFDWCxPQUFLLEVBQUUscUJBQXFCO0NBQzdCLENBQUMsQ0FBQzs7O0FBRUksSUFBSSxLQUFLLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDM0IsWUFBVSxFQUFFLGFBQWE7QUFDekIsR0FBQyxFQUFFLENBQUMsRUFBRTtBQUNOLEdBQUMsRUFBRSxDQUFDLEVBQUU7QUFDTixPQUFLLEVBQUUsRUFBRTtBQUNULFFBQU0sRUFBRSxFQUFFO0FBQ1YsT0FBSyxFQUFFLG9CQUFvQjtBQUMzQixTQUFPLEVBQUUsQ0FBQztDQUNYLENBQUMsQ0FBQzs7O0FBRUksSUFBSSxJQUFJLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDMUIsR0FBQyxFQUFFLEdBQUc7QUFDTixPQUFLLEVBQUUsR0FBRztBQUNWLFFBQU0sRUFBRSxFQUFFO0FBQ1YsTUFBSSxFQUFFLGdDQUFnQztBQUN0QyxpQkFBZSxFQUFFLGFBQWE7QUFDOUIsU0FBTyxFQUFFLENBQUM7Q0FDWCxDQUFDLENBQUE7O0FBQ0YsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDOztBQUVSLElBQUksS0FBSyxHQUFHLElBQUksS0FBSyxDQUFDO0FBQzNCLEdBQUMsRUFBRSxHQUFHO0FBQ04sT0FBSyxFQUFFLE1BQU0sQ0FBQyxLQUFLO0FBQ25CLFFBQU0sRUFBRSxHQUFHO0FBQ1gsaUJBQWUsRUFBRSxhQUFhO0FBQzlCLFNBQU8sRUFBRSxDQUFDO0NBQ1gsQ0FBQyxDQUFDOzs7QUFFSSxJQUFJLEtBQUssR0FBRyxJQUFJLEtBQUssQ0FBQztBQUMzQixZQUFVLEVBQUUsS0FBSztBQUNqQixHQUFDLEVBQUUsRUFBRTtBQUNMLEdBQUMsRUFBRSxHQUFHO0FBQ04sT0FBSyxFQUFFLEdBQUc7QUFDVixRQUFNLEVBQUUsR0FBRztBQUNYLGlCQUFlLEVBQUUsYUFBYTtBQUM5QixPQUFLLEVBQUUsQ0FBQztDQUNULENBQUMsQ0FBQzs7QUFDSCxJQUFJLFlBQVksR0FBRyxJQUFJLEtBQUssQ0FBQztBQUMzQixZQUFVLEVBQUUsS0FBSztBQUNqQixPQUFLLEVBQUUsR0FBRztBQUNWLFFBQU0sRUFBRSxHQUFHO0FBQ1gsT0FBSyxFQUFFLG9CQUFvQjtDQUM1QixDQUFDLENBQUM7QUFDSCxZQUFZLENBQUMsT0FBTyxFQUFFLENBQUM7QUFDdkIsSUFBSSxTQUFTLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDeEIsWUFBVSxFQUFFLEtBQUs7QUFDakIsR0FBQyxFQUFFLEdBQUc7QUFDTixPQUFLLEVBQUUsR0FBRztBQUNWLFFBQU0sRUFBRSxFQUFFO0FBQ1YsT0FBSyxFQUFFLHdCQUF3QjtDQUNoQyxDQUFDLENBQUM7O0FBRUksSUFBSSxLQUFLLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDM0IsWUFBVSxFQUFFLEtBQUs7QUFDakIsR0FBQyxFQUFFLEdBQUc7QUFDTixHQUFDLEVBQUUsR0FBRztBQUNOLE9BQUssRUFBRSxHQUFHO0FBQ1YsUUFBTSxFQUFFLEdBQUc7QUFDWCxpQkFBZSxFQUFFLGFBQWE7QUFDOUIsT0FBSyxFQUFFLENBQUM7Q0FDVCxDQUFDLENBQUM7O0FBQ0gsSUFBSSxZQUFZLEdBQUcsSUFBSSxLQUFLLENBQUM7QUFDM0IsWUFBVSxFQUFFLEtBQUs7QUFDakIsT0FBSyxFQUFFLEdBQUc7QUFDVixRQUFNLEVBQUUsR0FBRztBQUNYLE9BQUssRUFBRSxvQkFBb0I7Q0FDNUIsQ0FBQyxDQUFDO0FBQ0gsWUFBWSxDQUFDLE9BQU8sRUFBRSxDQUFDO0FBQ3ZCLElBQUksU0FBUyxHQUFHLElBQUksS0FBSyxDQUFDO0FBQ3hCLFlBQVUsRUFBRSxLQUFLO0FBQ2pCLEdBQUMsRUFBRSxHQUFHO0FBQ04sT0FBSyxFQUFFLEdBQUc7QUFDVixRQUFNLEVBQUUsRUFBRTtBQUNWLE9BQUssRUFBRSx3QkFBd0I7Q0FDaEMsQ0FBQyxDQUFDOzs7Ozs7OztzQkNsT3FCLFVBQVU7O0lBQXRCLE1BQU07O0FBRWxCLE1BQU0sQ0FBQyxLQUFLLENBQUMsTUFBTSxDQUFDLEdBQUcsQ0FBQyxjQUFjLEVBQUU7QUFDdEMsR0FBQyxFQUFFLE1BQU0sQ0FBQyxNQUFNLEdBQUcsR0FBRztDQUN2QixDQUFDLENBQUM7QUFDSCxNQUFNLENBQUMsS0FBSyxDQUFDLE1BQU0sQ0FBQyxHQUFHLENBQUMsY0FBYyxFQUFFO0FBQ3RDLEdBQUMsRUFBRSxNQUFNLENBQUMsTUFBTSxHQUFHLEdBQUc7Q0FDdkIsQ0FBQyxDQUFDOztBQUVILE1BQU0sQ0FBQyxjQUFjLENBQUMsTUFBTSxDQUFDLEdBQUcsQ0FBQyxRQUFRLEVBQUU7QUFDekMsU0FBTyxFQUFFLENBQUM7Q0FDWCxDQUFDLENBQUM7QUFDSCxNQUFNLENBQUMsS0FBSyxDQUFDLE1BQU0sQ0FBQyxHQUFHLENBQUMsUUFBUSxFQUFFO0FBQ2hDLFNBQU8sRUFBRSxDQUFDO0NBQ1gsQ0FBQyxDQUFDO0FBQ0gsTUFBTSxDQUFDLEtBQUssQ0FBQyxNQUFNLENBQUMsR0FBRyxDQUFDLFFBQVEsRUFBRTtBQUNoQyxTQUFPLEVBQUUsQ0FBQztDQUNYLENBQUMsQ0FBQztBQUNILE1BQU0sQ0FBQyxNQUFNLENBQUMsTUFBTSxDQUFDLEdBQUcsQ0FBQyxRQUFRLEVBQUU7QUFDakMsU0FBTyxFQUFFLENBQUM7Q0FDWCxDQUFDLENBQUM7QUFDSCxNQUFNLENBQUMsSUFBSSxDQUFDLE1BQU0sQ0FBQyxHQUFHLENBQUMsUUFBUSxFQUFFO0FBQy9CLFNBQU8sRUFBRSxDQUFDO0NBQ1gsQ0FBQyxDQUFDO0FBQ0gsTUFBTSxDQUFDLGFBQWEsQ0FBQyxNQUFNLENBQUMsR0FBRyxDQUFDLFFBQVEsRUFBRTtBQUN4QyxTQUFPLEVBQUUsQ0FBQztBQUNWLEdBQUMsRUFBRSxDQUFDO0FBQ0osR0FBQyxFQUFFLENBQUM7QUFDSixPQUFLLEVBQUUsTUFBTSxDQUFDLEtBQUs7QUFDbkIsUUFBTSxFQUFFLE1BQU0sQ0FBQyxNQUFNO0FBQ3JCLGNBQVksRUFBRSxDQUFDO0NBQ2hCLENBQUMsQ0FBQztBQUNILE1BQU0sQ0FBQyxrQkFBa0IsQ0FBQyxNQUFNLENBQUMsR0FBRyxDQUFDLFFBQVEsRUFBRTtBQUM3QyxTQUFPLEVBQUUsQ0FBQztBQUNWLE1BQUksRUFBRSxNQUFNLENBQUMsS0FBSyxHQUFDLENBQUM7QUFDcEIsTUFBSSxFQUFFLE1BQU0sQ0FBQyxNQUFNLEdBQUMsQ0FBQztBQUNyQixPQUFLLEVBQUUsTUFBTSxDQUFDLEtBQUssR0FBQyxHQUFHO0FBQ3ZCLFFBQU0sRUFBRSxNQUFNLENBQUMsS0FBSyxHQUFDLEdBQUc7Q0FDekIsQ0FBQyxDQUFDO0FBQ0gsTUFBTSxDQUFDLEtBQUssQ0FBQyxNQUFNLENBQUMsR0FBRyxDQUFDLFFBQVEsRUFBRTtBQUNoQyxHQUFDLEVBQUUsRUFBRTtBQUNMLEdBQUMsRUFBRSxFQUFFO0FBQ0wsU0FBTyxFQUFFLENBQUM7Q0FDWCxDQUFDLENBQUM7O0FBRUgsTUFBTSxDQUFDLEtBQUssQ0FBQyxTQUFTLENBQUMsT0FBTyxDQUFDLFVBQVMsS0FBSyxFQUFDO0FBQzVDLE9BQUssQ0FBQyxNQUFNLENBQUMsR0FBRyxDQUFDLGFBQWEsRUFBRTtBQUM5QixTQUFLLEVBQUUsQ0FBQztHQUNULENBQUMsQ0FBQztDQUNKLENBQUMsQ0FBQzs7QUFFSCxNQUFNLENBQUMsS0FBSyxDQUFDLE1BQU0sQ0FBQyxHQUFHLENBQUMsZ0JBQWdCLEVBQUU7QUFDeEMsTUFBSSxFQUFFLE1BQU0sQ0FBQyxLQUFLLEdBQUMsQ0FBQztBQUNwQixHQUFDLEVBQUUsRUFBRTtDQUNOLENBQUMsQ0FBQztBQUNILE1BQU0sQ0FBQyxLQUFLLENBQUMsTUFBTSxDQUFDLEdBQUcsQ0FBQyxvQkFBb0IsRUFBRTtBQUM1QyxHQUFDLEVBQUUsR0FBRztBQUNOLFNBQU8sRUFBRSxDQUFDO0NBQ1gsQ0FBQyxDQUFDO0FBQ0gsTUFBTSxDQUFDLEtBQUssQ0FBQyxNQUFNLENBQUMsR0FBRyxDQUFDLGdCQUFnQixFQUFFO0FBQ3hDLE1BQUksRUFBRSxNQUFNLENBQUMsS0FBSyxHQUFDLENBQUM7QUFDcEIsR0FBQyxFQUFFLEVBQUU7Q0FDTixDQUFDLENBQUM7QUFDSCxNQUFNLENBQUMsS0FBSyxDQUFDLE1BQU0sQ0FBQyxHQUFHLENBQUMsb0JBQW9CLEVBQUU7QUFDNUMsR0FBQyxFQUFFLEdBQUc7QUFDTixTQUFPLEVBQUUsQ0FBQztDQUNYLENBQUMsQ0FBQzs7QUFFSCxNQUFNLENBQUMsSUFBSSxDQUFDLE1BQU0sQ0FBQyxHQUFHLENBQUM7QUFDckIsT0FBSyxFQUFFO0FBQ0wsS0FBQyxFQUFFLEdBQUc7QUFDTixXQUFPLEVBQUUsQ0FBQztHQUNYO0FBQ0QsTUFBSSxFQUFFO0FBQ0osS0FBQyxFQUFFLEdBQUc7QUFDTixXQUFPLEVBQUUsQ0FBQztHQUNYO0NBQ0YsQ0FBQyxDQUFDOztBQUVILE1BQU0sQ0FBQyxXQUFXLENBQUMsTUFBTSxDQUFDLEdBQUcsQ0FBQyxZQUFZLEVBQUU7QUFDMUMsVUFBUSxFQUFFLEVBQUU7Q0FDYixDQUFDLENBQUM7O0FBRUgsTUFBTSxDQUFDLFdBQVcsQ0FBQyxNQUFNLENBQUMsR0FBRyxDQUFDLFlBQVksRUFBRTtBQUMxQyxVQUFRLEVBQUUsSUFBSTtDQUNmLENBQUMsQ0FBQyIsImZpbGUiOiJnZW5lcmF0ZWQuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlc0NvbnRlbnQiOlsiKGZ1bmN0aW9uIGUodCxuLHIpe2Z1bmN0aW9uIHMobyx1KXtpZighbltvXSl7aWYoIXRbb10pe3ZhciBhPXR5cGVvZiByZXF1aXJlPT1cImZ1bmN0aW9uXCImJnJlcXVpcmU7aWYoIXUmJmEpcmV0dXJuIGEobywhMCk7aWYoaSlyZXR1cm4gaShvLCEwKTt2YXIgZj1uZXcgRXJyb3IoXCJDYW5ub3QgZmluZCBtb2R1bGUgJ1wiK28rXCInXCIpO3Rocm93IGYuY29kZT1cIk1PRFVMRV9OT1RfRk9VTkRcIixmfXZhciBsPW5bb109e2V4cG9ydHM6e319O3Rbb11bMF0uY2FsbChsLmV4cG9ydHMsZnVuY3Rpb24oZSl7dmFyIG49dFtvXVsxXVtlXTtyZXR1cm4gcyhuP246ZSl9LGwsbC5leHBvcnRzLGUsdCxuLHIpfXJldHVybiBuW29dLmV4cG9ydHN9dmFyIGk9dHlwZW9mIHJlcXVpcmU9PVwiZnVuY3Rpb25cIiYmcmVxdWlyZTtmb3IodmFyIG89MDtvPHIubGVuZ3RoO28rKylzKHJbb10pO3JldHVybiBzfSkiLCJcbi8qKlxuICogV2VsY29tZSB0byBGcmFtZXJcbiAqXG4gKiBMZWFybiBob3cgdG8gcHJvdG90eXBlOlxuICogLSBodHRwOi8vZnJhbWVyanMuY29tL2xlYXJuXG4gKiAtIGh0dHBzOi8vZ2l0aHViLmNvbS9wZXRlc2NoYWZmbmVyL2ZyYW1lci1jbGlcbiAqL1xuaW1wb3J0ICcuL3NjcmlwdHMvY29udHJvbGxlcic7XG4iLCIjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcclxuIyBDcmVhdGVkIGJ5IEpvcmRhbiBSb2JlcnQgRG9ic29uIG9uIDE0IEF1Z3VzdCAyMDE1XHJcbiMgXHJcbiMgVXNlIHRvIG5vcm1hbGl6ZSBzY3JlZW4gJiBvZmZzZXQgeCx5IHZhbHVlcyBmcm9tIGNsaWNrIG9yIHRvdWNoIGV2ZW50cy5cclxuI1xyXG4jIFRvIEdldCBTdGFydGVkLi4uXHJcbiNcclxuIyAxLiBQbGFjZSB0aGlzIGZpbGUgaW4gRnJhbWVyIFN0dWRpbyBtb2R1bGVzIGRpcmVjdG9yeVxyXG4jXHJcbiMgMi4gSW4geW91ciBwcm9qZWN0IGluY2x1ZGU6XHJcbiMgICAgIHtQb2ludGVyfSA9IHJlcXVpcmUgXCJQb2ludGVyXCJcclxuI1xyXG4jIDMuIEZvciBzY3JlZW4gY29vcmRpbmF0ZXM6IFxyXG4jICAgICBidG4ub24gRXZlbnRzLkNsaWNrLCAoZXZlbnQsIGxheWVyKSAtPiBwcmludCBQb2ludGVyLnNjcmVlbihldmVudCwgbGF5ZXIpXHJcbiMgXHJcbiMgNC4gRm9yIGxheWVyIG9mZnNldCBjb29yZGluYXRlczogXHJcbiMgICAgIGJ0bi5vbiBFdmVudHMuQ2xpY2ssIChldmVudCwgbGF5ZXIpIC0+IHByaW50IFBvaW50ZXIub2Zmc2V0KGV2ZW50LCBsYXllcilcclxuI1xyXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcclxuXHJcbmNsYXNzIGV4cG9ydHMuUG9pbnRlclxyXG5cclxuICAgICMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xyXG4gICAgIyBQdWJsaWMgTWV0aG9kcyAjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXHJcblxyXG4gICAgQHNjcmVlbiA9IChldmVudCwgbGF5ZXIpIC0+XHJcbiAgICAgICAgc2NyZWVuQXJndW1lbnRFcnJvcigpIHVubGVzcyBldmVudD8gYW5kIGxheWVyP1xyXG4gICAgICAgIGUgPSBvZmZzZXRDb29yZHMgZXZlbnRcclxuICAgICAgICBpZiBlLnggYW5kIGUueVxyXG4gICAgICAgICAgICAjIE1vdXNlIEV2ZW50XHJcbiAgICAgICAgICAgIHNjcmVlbkNvb3JkcyA9IGxheWVyLnNjcmVlbkZyYW1lXHJcbiAgICAgICAgICAgIGUueCArPSBzY3JlZW5Db29yZHMueFxyXG4gICAgICAgICAgICBlLnkgKz0gc2NyZWVuQ29vcmRzLnlcclxuICAgICAgICBlbHNlXHJcbiAgICAgICAgICAgICMgVG91Y2ggRXZlbnRcclxuICAgICAgICAgICAgZSA9IGNsaWVudENvb3JkcyBldmVudFxyXG4gICAgICAgIHJldHVybiBlXHJcbiAgICAgICAgICAgIFxyXG4gICAgQG9mZnNldCA9IChldmVudCwgbGF5ZXIpIC0+XHJcbiAgICAgICAgb2Zmc2V0QXJndW1lbnRFcnJvcigpIHVubGVzcyBldmVudD8gYW5kIGxheWVyP1xyXG4gICAgICAgIGUgPSBvZmZzZXRDb29yZHMgZXZlbnRcclxuICAgICAgICB1bmxlc3MgZS54PyBhbmQgZS55P1xyXG4gICAgICAgICAgICAjIFRvdWNoIEV2ZW50XHJcbiAgICAgICAgICAgIGUgPSBjbGllbnRDb29yZHMgZXZlbnRcclxuICAgICAgICAgICAgdGFyZ2V0U2NyZWVuQ29vcmRzID0gbGF5ZXIuc2NyZWVuRnJhbWVcclxuICAgICAgICAgICAgZS54IC09IHRhcmdldFNjcmVlbkNvb3Jkcy54XHJcbiAgICAgICAgICAgIGUueSAtPSB0YXJnZXRTY3JlZW5Db29yZHMueVxyXG4gICAgICAgIHJldHVybiBlXHJcbiAgICBcclxuICAgICMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xyXG4gICAgIyBQcml2YXRlIEhlbHBlciBNZXRob2RzICMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXHJcbiAgICBcclxuICAgIG9mZnNldENvb3JkcyA9IChldikgIC0+IGUgPSBFdmVudHMudG91Y2hFdmVudCBldjsgcmV0dXJuIGNvb3JkcyBlLm9mZnNldFgsIGUub2Zmc2V0WVxyXG4gICAgY2xpZW50Q29vcmRzID0gKGV2KSAgLT4gZSA9IEV2ZW50cy50b3VjaEV2ZW50IGV2OyByZXR1cm4gY29vcmRzIGUuY2xpZW50WCwgZS5jbGllbnRZXHJcbiAgICBjb29yZHMgICAgICAgPSAoeCx5KSAtPiByZXR1cm4geDp4LCB5OnlcclxuICAgIFxyXG4gICAgIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXHJcbiAgICAjIEVycm9yIEhhbmRsZXIgTWV0aG9kcyAjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcclxuICAgIFxyXG4gICAgc2NyZWVuQXJndW1lbnRFcnJvciA9IC0+XHJcbiAgICAgICAgZXJyb3IgbnVsbFxyXG4gICAgICAgIGNvbnNvbGUuZXJyb3IgXCJcIlwiXHJcbiAgICAgICAgICAgIFBvaW50ZXIuc2NyZWVuKCkgRXJyb3I6IFlvdSBtdXN0IHBhc3MgZXZlbnQgJiBsYXllciBhcmd1bWVudHMuIFxcblxyXG4gICAgICAgICAgICBFeGFtcGxlOiBsYXllci5vbiBFdmVudHMuVG91Y2hTdGFydCwoZXZlbnQsbGF5ZXIpIC0+IFBvaW50ZXIuc2NyZWVuKGV2ZW50LCBsYXllcilcIlwiXCJcclxuICAgICAgICAgICAgXHJcbiAgICBvZmZzZXRBcmd1bWVudEVycm9yID0gLT5cclxuICAgICAgICBlcnJvciBudWxsXHJcbiAgICAgICAgY29uc29sZS5lcnJvciBcIlwiXCJcclxuICAgICAgICAgICAgUG9pbnRlci5vZmZzZXQoKSBFcnJvcjogWW91IG11c3QgcGFzcyBldmVudCAmIGxheWVyIGFyZ3VtZW50cy4gXFxuXHJcbiAgICAgICAgICAgIEV4YW1wbGU6IGxheWVyLm9uIEV2ZW50cy5Ub3VjaFN0YXJ0LChldmVudCxsYXllcikgLT4gUG9pbnRlci5vZmZzZXQoZXZlbnQsIGxheWVyKVwiXCJcIiIsIiMgTW9kdWxlIGNyZWF0ZWQgYnkgQWFyb24gSmFtZXMgfCBOb3ZlbWJlciAyNHRoLCAyMDE1XHJcbiNcclxuIyBQb2ludGVyIE1vZHVsZSBieSBKb3JkYW4gRG9ic29uIGlzIHJlcXVpcmVkIGZvciB0aGlzIG1vZHVsZVxyXG4jIEluc3RhbGwgdGhpcyBtb2R1bGUgZmlyc3QgaGVyZTogaHR0cDovL2JpdC5seS8xbGdtTnBUXHJcbiNcclxuIyBBZGQgdGhlIGZvbGxvd2luZyBsaW5lIGF0IHRoZSB0b3Agb2YgeW91ciBwcm9qZWN0IHRvIGFjY2VzcyB0aGlzIG1vZHVsZTpcclxuIyBhbmRyb2lkID0gcmVxdWlyZSBcImFuZHJvaWRSaXBwbGVcIlxyXG4jXHJcbiMgVG8gYWRkIHJpcHBsZSB0byBsYXllciwgdXNlIHRoaXMgbGluZSBvZiBjb2RlOlxyXG4jIGxheWVyTmFtZS5vbihFdmVudHMuQ2xpY2ssIGFuZHJvaWQucmlwcGxlKVxyXG4jIFJlcGxhY2UgbGF5ZXJOYW1lIHdpdGggdGhlIG5hbWUgb2YgeW91ciBsYXllclxyXG4jXHJcbiMgQXZhaWxhYmxlIG9wdGlvbnM6XHJcbiMgWW91IGNhbiB1c2UgYW55IEV2ZW50IHdpdGggdGhpcyBtb2R1bGVcclxuXHJcbntQb2ludGVyfSA9IHJlcXVpcmUgXCIuL1BvaW50ZXJcIlxyXG5cclxuIyBjcmVhdGUgcmlwcGxlIGZ1bmN0aW9uXHJcbmV4cG9ydHMucmlwcGxlID0gKGV2ZW50LCBsYXllcikgLT5cclxuICAgIGV2ZW50Q29vcmRzID0gUG9pbnRlci5vZmZzZXQoZXZlbnQsIGxheWVyKVxyXG5cclxuICAgICMgQ2hhbmdlIGNvbG9yIG9mIHJpcHBsZVxyXG4gICAgY29sb3IgPSBcImJsYWNrXCJcclxuICAgIGFuaW1hdGlvbiA9IGN1cnZlOiBcImVhc2Utb3V0XCIsIHRpbWU6IC40XHJcblxyXG4gICAgIyBDcmVhdGUgbGF5ZXJzIG9uIENsaWNrXHJcbiAgICBwcmVzc0ZlZWRiYWNrID0gbmV3IExheWVyXHJcbiAgICAgICAgc3VwZXJMYXllcjogQFxyXG4gICAgICAgIG5hbWU6IFwicHJlc3NGZWVkYmFja1wiXHJcbiAgICAgICAgd2lkdGg6IGxheWVyLndpZHRoXHJcbiAgICAgICAgaGVpZ2h0OiBsYXllci5oZWlnaHRcclxuICAgICAgICBvcGFjaXR5OiAwXHJcbiAgICAgICAgYmFja2dyb3VuZENvbG9yOiBjb2xvclxyXG4gICAgcHJlc3NGZWVkYmFjay5zdGF0ZXMuYWRkXHJcbiAgICAgICAgcHJlc3NlZDogb3BhY2l0eTogLjA0XHJcbiAgICBwcmVzc0ZlZWRiYWNrLnN0YXRlcy5zd2l0Y2goXCJwcmVzc2VkXCIsIGFuaW1hdGlvbilcclxuXHJcbiAgICByaXBwbGVDaXJjbGUgPSBuZXcgTGF5ZXJcclxuICAgICAgICBzdXBlckxheWVyOiBAXHJcbiAgICAgICAgbmFtZTogXCJyaXBwbGVDaXJjbGVcIlxyXG4gICAgICAgIGJvcmRlclJhZGl1czogXCI1MCVcIlxyXG4gICAgICAgIG1pZFg6IGV2ZW50Q29vcmRzLnhcclxuICAgICAgICBtaWRZOiBldmVudENvb3Jkcy55XHJcbiAgICAgICAgb3BhY2l0eTogLjE2XHJcbiAgICAgICAgYmFja2dyb3VuZENvbG9yOiBjb2xvclxyXG4gICAgcmlwcGxlQ2lyY2xlLnN0YXRlcy5hZGRcclxuICAgICAgICBwcmVzc2VkOiBzY2FsZTogbGF5ZXIud2lkdGggLyA2MCwgb3BhY2l0eTogMCxcclxuICAgIHJpcHBsZUNpcmNsZS5zdGF0ZXMuc3dpdGNoKFwicHJlc3NlZFwiLCBhbmltYXRpb24pXHJcblxyXG4gICAgIyBEZXN0cm95IGxheWVycyBhZnRlciBDbGlja1xyXG4gICAgVXRpbHMuZGVsYXkgMC4zLCAtPlxyXG4gICAgICAgIHByZXNzRmVlZGJhY2suc3RhdGVzLm5leHQoXCJkZWZhdWx0XCIsIGFuaW1hdGlvbilcclxuICAgICAgICBwcmVzc0ZlZWRiYWNrLm9uIEV2ZW50cy5BbmltYXRpb25FbmQsIC0+XHJcbiAgICAgICAgICAgIHJpcHBsZUNpcmNsZS5kZXN0cm95KClcclxuICAgICAgICAgICAgcHJlc3NGZWVkYmFjay5kZXN0cm95KCkiLCIvLyBpbXBvcnQgRmlyZWJhc2UgZnJvbSAnZmlyZWJhc2UnO1xyXG5cclxuLy8gY29uc3QgZmIgPSB7XHJcbi8vICAgdXJsOiAnaHR0cHM6Ly9jb25uZWN0cHJvdG90eXBlcy5maXJlYmFzZWlvLmNvbS8nXHJcbi8vIH07XHJcblxyXG4vLyBsZXQgcmVmID0gbmV3IEZpcmViYXNlKGZiLnVybCk7XHJcbi8vIHJlZi5vbigndmFsdWUnLCAoKT0+e1xyXG4vLyAgIGNvbnNvbGUubG9nKGFyZ3VtZW50cyk7XHJcbi8vIH0pO1xyXG5cclxudmFyIHJlZiA9ICdmYk9iamVjdCc7XHJcblxyXG5leHBvcnQgZGVmYXVsdCByZWY7IiwiaW1wb3J0ICogYXMgbGF5ZXJzIGZyb20gJy4vbGF5ZXJzJztcclxuaW1wb3J0ICcuL3N0YXRlcyc7XHJcbmltcG9ydCBjb25uZWN0b3IgZnJvbSAnLi9jb25uZWN0b3InO1xyXG5cclxuZnVuY3Rpb24gc2NlbmUgKHN0YXRlLCBvcHRpb24pIHtcclxuICBGcmFtZXIuQ3VycmVudENvbnRleHQuX2xheWVyTGlzdC5mb3JFYWNoKGZ1bmN0aW9uKGxheWVyKXtcclxuICAgIGlmKGxheWVyLl9zdGF0ZXMgJiYgbGF5ZXIuX3N0YXRlcy5fb3JkZXJlZFN0YXRlcy5pbmRleE9mKHN0YXRlKSA+PSAwKXtcclxuICAgICAgbGF5ZXIuc3RhdGVzLnN3aXRjaChzdGF0ZSwgb3B0aW9uKTtcclxuICAgIH1cclxuICB9KTtcclxufVxyXG5cclxubGV0IGVhcnRoUm9sbGluZ1RvZ2dsZSA9IHRydWU7XHJcblxyXG5mdW5jdGlvbiBlYXJ0aFJvbGxpbmcodGltZXN0YW1wKSB7XHJcbiAgbGV0IHIxID0gTWF0aC5jb3ModGltZXN0YW1wLzEwMDApKjU7XHJcbiAgbGV0IHIyID0gTWF0aC5zaW4odGltZXN0YW1wLzEwMDApKjU7XHJcbiAgbGF5ZXJzLmVhcnRoLmFuaW1hdGUoe1xyXG4gICAgcHJvcGVydGllczoge1xyXG4gICAgICByb3RhdGlvbjogcjFcclxuICAgIH1cclxuICB9KTtcclxuICBsYXllcnMuY2xvdWQxLmFuaW1hdGUoe1xyXG4gICAgcHJvcGVydGllczoge1xyXG4gICAgICByb3RhdGlvbjogcjJcclxuICAgIH1cclxuICB9KTtcclxuICBsYXllcnMuY2xvdWQyLmFuaW1hdGUoe1xyXG4gICAgcHJvcGVydGllczoge1xyXG4gICAgICByb3RhdGlvbjogcjIsXHJcbiAgICAgIHg6IHIyKjVcclxuICAgIH1cclxuICB9KTtcclxuICBsYXllcnMucGhvbmUuYW5pbWF0ZSh7XHJcbiAgICBwcm9wZXJ0aWVzOiB7XHJcbiAgICAgIHJvdGF0aW9uOiByMSouM1xyXG4gICAgfVxyXG4gIH0pO1xyXG4gIGlmKGVhcnRoUm9sbGluZ1RvZ2dsZSkgd2luZG93LnJlcXVlc3RBbmltYXRpb25GcmFtZShlYXJ0aFJvbGxpbmcpO1xyXG59XHJcbmxldCBlYXJ0aFJvbGxpbmdTdGFydCA9ICgpPT4ge1xyXG4gIGVhcnRoUm9sbGluZ1RvZ2dsZSA9IHRydWU7XHJcbiAgd2luZG93LnJlcXVlc3RBbmltYXRpb25GcmFtZShlYXJ0aFJvbGxpbmcpO1xyXG59XHJcbmxldCBlYXJ0aFJvbGxpbmdTdG9wID0gKCk9PiB7XHJcbiAgZWFydGhSb2xsaW5nVG9nZ2xlID0gZmFsc2U7XHJcbiAgc2V0VGltZW91dChmdW5jdGlvbigpe1xyXG4gICAgW2xheWVycy5lYXJ0aCwgbGF5ZXJzLmNsb3VkMSwgbGF5ZXJzLmNsb3VkMl0uZm9yRWFjaChmdW5jdGlvbihsKXtcclxuICAgICAgbC5hbmltYXRlKHtcclxuICAgICAgICBwcm9wZXJ0aWVzOiB7XHJcbiAgICAgICAgICByb3RhdGlvbjogMFxyXG4gICAgICAgIH1cclxuICAgICAgfSk7XHJcbiAgICB9KTtcclxuICB9LCAxMDApO1xyXG59XHJcblxyXG5cclxuY2xhc3MgV2F2ZSB7XHJcbiAgY29uc3RydWN0b3IocGFyZW50KSB7XHJcbiAgICB0aGlzLndhdmUxID0gbmV3IExheWVyKHtcclxuICAgICAgc3VwZXJMYXllcjogcGFyZW50LFxyXG4gICAgICBtaWRYOiBwYXJlbnQuaGVpZ2h0LzIsXHJcbiAgICAgIG1pZFk6IHBhcmVudC5oZWlnaHQvMixcclxuICAgICAgd2lkdGg6IHBhcmVudC53aWR0aCxcclxuICAgICAgaGVpZ2h0OiBwYXJlbnQuaGVpZ2h0LFxyXG4gICAgICBzY2FsZTogMCxcclxuICAgICAgYmFja2dyb3VuZENvbG9yOiAnIzAwYTJmNCcsXHJcbiAgICAgIGJvcmRlclJhZGl1czogcGFyZW50LmhlaWdodFxyXG4gICAgfSk7XHJcbiAgICB0aGlzLndhdmUyID0gbmV3IExheWVyKHtcclxuICAgICAgc3VwZXJMYXllcjogcGFyZW50LFxyXG4gICAgICBtaWRYOiBwYXJlbnQuaGVpZ2h0LzIsXHJcbiAgICAgIG1pZFk6IHBhcmVudC5oZWlnaHQvMixcclxuICAgICAgd2lkdGg6IHBhcmVudC53aWR0aCxcclxuICAgICAgaGVpZ2h0OiBwYXJlbnQuaGVpZ2h0LFxyXG4gICAgICBzY2FsZTogdGhpcy53YXZlMS5zY2FsZSowLjYsXHJcbiAgICAgIGJhY2tncm91bmRDb2xvcjogJyMwMDkxZWEnLFxyXG4gICAgICBib3JkZXJSYWRpdXM6IHBhcmVudC5oZWlnaHRcclxuICAgIH0pO1xyXG4gIH1cclxuICBtb3ZlKCl7XHJcbiAgICB0aGlzLndhdmUxLmFuaW1hdGUoe1xyXG4gICAgICBwcm9wZXJ0aWVzOiB7XHJcbiAgICAgICAgc2NhbGU6IDEuMVxyXG4gICAgICB9LFxyXG4gICAgICB0aW1lOiA1LFxyXG4gICAgICBjdXJ2ZTogXCJjdWJpYy1iZXppZXIoLjI4LC4zNiwuOTEsLjU3KVwiXHJcbiAgICB9KTtcclxuICAgIFV0aWxzLmRlbGF5KDAuMiwgKCk9PntcclxuICAgICAgdGhpcy53YXZlMi5hbmltYXRlKHtcclxuICAgICAgICBwcm9wZXJ0aWVzOiB7XHJcbiAgICAgICAgICBzY2FsZTogMVxyXG4gICAgICAgIH0sXHJcbiAgICAgICAgdGltZTogNSxcclxuICAgICAgICBjdXJ2ZTogXCJjdWJpYy1iZXppZXIoLjI4LC4zNiwuOTEsLjU3KVwiXHJcbiAgICAgIH0pO1xyXG4gICAgICB0aGlzLndhdmUyLm9uKEV2ZW50cy5BbmltYXRpb25FbmQsICgpPT57XHJcbiAgICAgICAgdGhpcy5lbmQoKTtcclxuICAgICAgfSk7XHJcbiAgICB9KTtcclxuICB9XHJcbiAgZW5kKCl7XHJcbiAgICB0aGlzLndhdmUxLmRlc3Ryb3koKTtcclxuICAgIHRoaXMud2F2ZTIuZGVzdHJveSgpO1xyXG4gIH1cclxufVxyXG5cclxuZnVuY3Rpb24gd2F2ZVN0YXJ0KCl7XHJcbiAgbGV0IHdhdmUgPSBuZXcgV2F2ZShsYXllcnMuc2lnbmFsV3JhcHBlcik7XHJcbiAgd2F2ZS5tb3ZlKCk7XHJcbiAgVXRpbHMuZGVsYXkoMS40LCAoKT0+e1xyXG4gICAgaWYod2F2ZVN0YXRlKSB3YXZlU3RhcnQoKTtcclxuICB9KTtcclxufVxyXG5cclxuZnVuY3Rpb24gd2F2ZVN0b3AoKXtcclxuICB3YXZlU3RhdGUgPSBmYWxzZTtcclxufVxyXG5cclxudmFyIHdhdmVTdGF0ZSA9IGZhbHNlO1xyXG5cclxubGF5ZXJzLmNvbm5lY3RXcmFwcGVyLm9uKEV2ZW50cy5DbGljaywgZnVuY3Rpb24oKXtcclxuICBVdGlscy5kZWxheSgwLjMsIGZ1bmN0aW9uKCl7XHJcbiAgICBzY2VuZSgnZXhwYW5kJyk7XHJcbiAgfSk7XHJcbiAgZWFydGhSb2xsaW5nU3RhcnQoKTtcclxuICB3YXZlU3RhdGUgPSB0cnVlO1xyXG4gIHdhdmVTdGFydCgpO1xyXG4gIFV0aWxzLmRlbGF5KDAuNywgZnVuY3Rpb24oKXtcclxuICAgIHNjZW5lKCdjb25uZWN0U3RhcnQnLCB7IHRpbWU6IDAuNCwgY3VydmU6IFwiY3ViaWMtYmV6aWVyKC45LC4wOCwuNDQsLjk3KVwiIH0pO1xyXG4gIH0pO1xyXG4gIFV0aWxzLmRlbGF5KDEuOCwgZnVuY3Rpb24oKXtcclxuICAgIHNjZW5lKCdmaW5kRGV2aWNlcycsIHsgdGltZTogMC4zLCBjdXJ2ZTogXCJzcHJpbmcoMjAwLCAyMCwgMClcIiB9KTtcclxuICB9KTtcclxufSk7XHJcblxyXG5sYXllcnMuY2xvc2Uub24oRXZlbnRzLkNsaWNrLCAoKT0+e1xyXG4gIHNjZW5lKCdkZWZhdWx0Jyk7XHJcbiAgd2F2ZVN0b3AoKTtcclxuICBjb25zb2xlLmxvZyhhcmd1bWVudHMpO1xyXG59KTtcclxuXHJcbmxldCBhbmRyb2lkID0gcmVxdWlyZSgnYW5kcm9pZFJpcHBsZScpO1xyXG5sYXllcnMuY29ubmVjdEJ1dHRvbi5vbihFdmVudHMuQ2xpY2ssIGFuZHJvaWQucmlwcGxlKTtcclxuXHJcbmxheWVycy51c2Vycy5zdWJMYXllcnMuZm9yRWFjaChmdW5jdGlvbih1c2VyKXtcclxuICB1c2VyLm9uKEV2ZW50cy5Ub3VjaFN0YXJ0LCBmdW5jdGlvbihlLCBsYXllcil7XHJcbiAgICBsYXllci5hbmltYXRlKHtcclxuICAgICAgcHJvcGVydGllczoge1xyXG4gICAgICAgIHNjYWxlOiAxLjJcclxuICAgICAgfVxyXG4gICAgfSlcclxuICB9KTtcclxuICB1c2VyLm9uKEV2ZW50cy5Ub3VjaEVuZCwgZnVuY3Rpb24oZSwgbGF5ZXIpe1xyXG4gICAgbGF5ZXJzLnRleHQuc3RhdGVzLnN3aXRjaCgnb3V0JywgeyB0aW1lOiAwLjEgfSk7XHJcbiAgICBVdGlscy5kZWxheSgwLjMsICgpPT57XHJcbiAgICAgIGxheWVycy50ZXh0Lmh0bWwgPSAnPGgxPkNvbm5lY3RpbmcuLi48L2gxPidcclxuICAgICAgbGF5ZXJzLnRleHQuc3RhdGVzLnN3aXRjaCgnaW4nLCB7IHRpbWU6IDAuMSB9KTtcclxuICAgIH0pO1xyXG4gICAgbGF5ZXIuYW5pbWF0ZSh7XHJcbiAgICAgIHByb3BlcnRpZXM6IHtcclxuICAgICAgICBzY2FsZTogMVxyXG4gICAgICB9XHJcbiAgICB9KTtcclxuICAgIHVzZXIuc3RhdGVzLnN3aXRjaCgnY29ubmVjdFJlcXVlc3QnKTtcclxuICAgIGxheWVycy51c2Vycy5zdWJMYXllcnMuZm9yRWFjaCgoc3ViKT0+e1xyXG4gICAgICBpZihzdWIgIT09IHVzZXIpe1xyXG4gICAgICAgIHN1Yi5zdGF0ZXMuc3dpdGNoKCdjb25uZWN0UmVxdWVzdEhpZGUnKTtcclxuICAgICAgfVxyXG4gICAgfSk7XHJcbiAgICBVdGlscy5kZWxheSgwLjUsICgpPT57XHJcbiAgICAgIHNjZW5lKCdjb25uZWN0aW5nJyk7XHJcbiAgICB9KTtcclxuICB9KTtcclxufSk7IiwiRnJhbWVyLkRldmljZSA9IG5ldyBGcmFtZXIuRGV2aWNlVmlldygpO1xyXG5GcmFtZXIuRGV2aWNlLnNldHVwQ29udGV4dCgpO1xyXG5GcmFtZXIuRGV2aWNlLmRldmljZVR5cGUgPSBcImlwaG9uZS02LWdvbGRcIjtcclxuRnJhbWVyLkRlZmF1bHRzLkFuaW1hdGlvbiA9IHsgY3VydmU6IFwic3ByaW5nKDMwMCwzMCwwKVwiIH07XHJcbmNvbnN0IGNvbG9yID0ge1xyXG4gIGJhY2tncm91bmQ6ICcjZjRmNGY0JyxcclxuICBjb25uZWN0QnV0dG9uOiAnI2ZmZicsXHJcbiAgY29ubmVjdEJ1dHRvblRleHQ6ICcjMDA5MWVhJyxcclxuICBjb25uZWN0QmFjazogJyMwMDkxZWEnLFxyXG4gIHNpZ25hbDogJyMwMGEyZjQnXHJcbn07XHJcblxyXG5sZXQgYmFja2dyb3VuZCA9IG5ldyBCYWNrZ3JvdW5kTGF5ZXIoe1xyXG4gIGJhY2tncm91bmRDb2xvcjogY29sb3IuYmFja2dyb3VuZFxyXG59KTtcclxuXHJcbmV4cG9ydCBsZXQgY29ubmVjdEJ1dHRvbiA9IG5ldyBMYXllcih7XHJcbiAgd2lkdGg6IDQ4MCxcclxuICBoZWlnaHQ6IDgwLFxyXG4gIGJhY2tncm91bmRDb2xvcjogJ3RyYW5zcGFyZW50JyxcclxuICBmb3JjZTJkOiB0cnVlLFxyXG4gIHNoYWRvd1k6IDMsXHJcbiAgc2hhZG93Qmx1cjogMTIsXHJcbiAgc2hhZG93Q29sb3I6IFwicmdiYSgwLDAsMCwwLjIpXCIsXHJcbiAgYm9yZGVyUmFkaXVzOiAxMlxyXG5cclxufSk7XHJcbmNvbm5lY3RCdXR0b24uY2VudGVyKCk7XHJcblxyXG5leHBvcnQgbGV0IGNvbm5lY3RXcmFwcGVyID0gbmV3IExheWVyKHtcclxuICBzdXBlckxheWVyOiBjb25uZWN0QnV0dG9uLFxyXG4gIHdpZHRoOiA0ODAsXHJcbiAgaGVpZ2h0OiA4MCxcclxuICBvcGFjaXR5OiAxLFxyXG4gIGJhY2tncm91bmRDb2xvcjogY29sb3IuY29ubmVjdEJ1dHRvbixcclxufSk7XHJcbmNvbm5lY3RXcmFwcGVyLmNlbnRlcigpO1xyXG5cclxubGV0IGNvbm5lY3RCdXR0b25UZXh0ID0gbmV3IExheWVyKHtcclxuICBzdXBlckxheWVyOiBjb25uZWN0V3JhcHBlcixcclxuICB3aWR0aDogMjUwLFxyXG4gIGhlaWdodDogMzAsXHJcbiAgaHRtbDogJ0Nvbm5lY3QnLFxyXG4gIGJhY2tncm91bmRDb2xvcjogY29sb3IuY29ubmVjdEJ1dHRvbixcclxuICBzdHlsZToge1xyXG4gICAgJ2ZvbnQtc2l6ZSc6ICczMHB4JyxcclxuICAgICdjb2xvcic6IGNvbG9yLmNvbm5lY3RCdXR0b25UZXh0LFxyXG4gICAgJ3RleHQtYWxpZ24nOiAnY2VudGVyJyxcclxuICAgICdsaW5lLWhlaWdodCc6IDFcclxuICB9XHJcbn0pO1xyXG5jb25uZWN0QnV0dG9uVGV4dC5jZW50ZXIoKTtcclxuXHJcbmV4cG9ydCBsZXQgY29ubmVjdFdyYXBwZXJCYWNrID0gbmV3IExheWVyKHtcclxuICBzdXBlckxheWVyOiBjb25uZWN0QnV0dG9uLFxyXG4gIHdpZHRoOiA0MCxcclxuICBoZWlnaHQ6IDQwLFxyXG4gIGJhY2tncm91bmRDb2xvcjogY29sb3IuY29ubmVjdEJ1dHRvblRleHQsXHJcbiAgb3BhY2l0eTogMCxcclxuICBib3JkZXJSYWRpdXM6IDMwMDBcclxufSk7XHJcbmNvbm5lY3RXcmFwcGVyQmFjay5jZW50ZXIoKTtcclxuXHJcbmV4cG9ydCBsZXQgc2lnbmFsID0gbmV3IExheWVyKHtcclxuICBzdXBlckxheWVyOiBjb25uZWN0QnV0dG9uLFxyXG4gIG1pZFg6IFNjcmVlbi53aWR0aC8yLFxyXG4gIHk6IDIwMCxcclxuICAvLyB3aWR0aDogU2NyZWVuLmhlaWdodCoxLjMsXHJcbiAgLy8gaGVpZ2h0OiBTY3JlZW4uaGVpZ2h0KjEuMyxcclxuICB3aWR0aDogOTAwLFxyXG4gIGhlaWdodDogOTAwLFxyXG4gIHJvdGF0aW9uOiAyMjIsXHJcbiAgb3BhY2l0eTogMCxcclxuICBiYWNrZ3JvdW5kQ29sb3I6ICd0cmFuc3BhcmVudCdcclxufSk7XHJcblxyXG5leHBvcnQgbGV0IHNpZ25hbFdyYXBwZXIgPSBuZXcgTGF5ZXIoe1xyXG4gIHN1cGVyTGF5ZXI6IHNpZ25hbCxcclxuICBtaWRYOiAwLFxyXG4gIG1pZFk6IDAsXHJcbiAgd2lkdGg6IHNpZ25hbC53aWR0aCxcclxuICBoZWlnaHQ6IHNpZ25hbC5oZWlnaHQsXHJcbiAgc2NhbGU6IDIsXHJcbiAgYmFja2dyb3VuZENvbG9yOiAndHJhbnNwYXJlbnQnLFxyXG4gIGJvcmRlclJhZGl1czogc2lnbmFsLmhlaWdodFxyXG59KTtcclxuXHJcbmV4cG9ydCBsZXQgc2lnbmFsTGluZTEgPSBuZXcgTGF5ZXIoe1xyXG4gIHN1cGVyTGF5ZXI6IHNpZ25hbCxcclxuICB4OiAtMjAsXHJcbiAgeTogMCxcclxuICByb3RhdGlvbjogOTAsXHJcbiAgd2lkdGg6IFNjcmVlbi5oZWlnaHQsXHJcbiAgaGVpZ2h0OiA0MDAsXHJcbiAgYmFja2dyb3VuZENvbG9yOiBjb2xvci5jb25uZWN0QmFjayxcclxuICBvcmlnaW5ZOiAwLFxyXG4gIG9yaWdpblg6IDBcclxufSk7XHJcbmV4cG9ydCBsZXQgc2lnbmFsTGluZTIgPSBuZXcgTGF5ZXIoe1xyXG4gIHN1cGVyTGF5ZXI6IHNpZ25hbCxcclxuICB4OiAxODAsXHJcbiAgeTogLTQwMCxcclxuICByb3RhdGlvbjogMCxcclxuICB3aWR0aDogU2NyZWVuLmhlaWdodCxcclxuICBoZWlnaHQ6IDQwMCxcclxuICBiYWNrZ3JvdW5kQ29sb3I6IGNvbG9yLmNvbm5lY3RCYWNrLFxyXG4gIG9yaWdpblk6IDAsXHJcbiAgb3JpZ2luWDogMFxyXG59KTtcclxuXHJcbmV4cG9ydCBsZXQgcGhvbmUgPSBuZXcgTGF5ZXIoe1xyXG4gIHN1cGVyTGF5ZXI6IGNvbm5lY3RCdXR0b24sXHJcbiAgbWlkWDogU2NyZWVuLndpZHRoLzIsXHJcbiAgeTogU2NyZWVuLmhlaWdodCxcclxuICB3aWR0aDogMjUwLFxyXG4gIGhlaWdodDogNDI2LFxyXG4gIGltYWdlOiAnLi9pbWFnZXMvZGV2aWNlLnBuZycsXHJcbiAgb3JpZ2luWTogMS4yXHJcbn0pO1xyXG5cclxuZXhwb3J0IGxldCBlYXJ0aCA9IG5ldyBMYXllcih7XHJcbiAgc3VwZXJMYXllcjogY29ubmVjdEJ1dHRvbixcclxuICB5OiBTY3JlZW4uaGVpZ2h0LFxyXG4gIHdpZHRoOiBTY3JlZW4ud2lkdGgsXHJcbiAgaGVpZ2h0OiA0NjYqMyxcclxuICBiYWNrZ3JvdW5kQ29sb3I6ICd0cmFuc3BhcmVudCcsXHJcbiAgc2NhbGU6IDEuMDVcclxufSk7XHJcblxyXG5leHBvcnQgbGV0IGNsb3VkMSA9IG5ldyBMYXllcih7XHJcbiAgc3VwZXJMYXllcjogZWFydGgsXHJcbiAgeTogOTUsXHJcbiAgd2lkdGg6IFNjcmVlbi53aWR0aCxcclxuICBoZWlnaHQ6IDI5NSxcclxuICBpbWFnZTogJy4vaW1hZ2VzL2Nsb3Vkcy5wbmcnXHJcbn0pO1xyXG5cclxubGV0IGxhbmQgPSBuZXcgTGF5ZXIoe1xyXG4gIHN1cGVyTGF5ZXI6IGVhcnRoLFxyXG4gIHdpZHRoOiBTY3JlZW4ud2lkdGgsXHJcbiAgaGVpZ2h0OiA0NjYsXHJcbiAgaW1hZ2U6ICcuL2ltYWdlcy9lYXJ0aC5wbmcnXHJcbn0pO1xyXG5sYW5kLmNlbnRlclgoKTtcclxuXHJcbmV4cG9ydCBsZXQgY2xvdWQyID0gbmV3IExheWVyKHtcclxuICBzdXBlckxheWVyOiBlYXJ0aCxcclxuICB5OiAxMjAsXHJcbiAgd2lkdGg6IFNjcmVlbi53aWR0aCxcclxuICBoZWlnaHQ6IDQwMCxcclxuICBpbWFnZTogJy4vaW1hZ2VzL2Nsb3Vkcy5wbmcnXHJcbn0pO1xyXG5cclxuZXhwb3J0IGxldCBjbG9zZSA9IG5ldyBMYXllcih7XHJcbiAgc3VwZXJMYXllcjogY29ubmVjdEJ1dHRvbixcclxuICB4OiAtMzksXHJcbiAgeTogLTM5LFxyXG4gIHdpZHRoOiAzOSxcclxuICBoZWlnaHQ6IDM5LFxyXG4gIGltYWdlOiAnLi9pbWFnZXMvY2xvc2UucG5nJyxcclxuICBvcGFjaXR5OiAwLFxyXG59KTtcclxuXHJcbmV4cG9ydCBsZXQgdGV4dCA9IG5ldyBMYXllcih7XHJcbiAgeTogMjUwLFxyXG4gIHdpZHRoOiAzODAsXHJcbiAgaGVpZ2h0OiA0OCxcclxuICBodG1sOiAnPGgxPldhaXRpbmcgZm9yIGNvbm5lY3QuLjwvaDE+JyxcclxuICBiYWNrZ3JvdW5kQ29sb3I6ICd0cmFuc3BhcmVudCcsXHJcbiAgb3BhY2l0eTogMFxyXG59KVxyXG50ZXh0LmNlbnRlclgoKTtcclxuXHJcbmV4cG9ydCBsZXQgdXNlcnMgPSBuZXcgTGF5ZXIoe1xyXG4gIHk6IDMwMCxcclxuICB3aWR0aDogU2NyZWVuLndpZHRoLFxyXG4gIGhlaWdodDogNTAwLFxyXG4gIGJhY2tncm91bmRDb2xvcjogJ3RyYW5zcGFyZW50JyxcclxuICBvcGFjaXR5OiAwXHJcbn0pO1xyXG5cclxuZXhwb3J0IGxldCB1c2VyMSA9IG5ldyBMYXllcih7XHJcbiAgc3VwZXJMYXllcjogdXNlcnMsXHJcbiAgeDogNjAsXHJcbiAgeTogMTEyLFxyXG4gIHdpZHRoOiAxMDUsXHJcbiAgaGVpZ2h0OiAyMDAsXHJcbiAgYmFja2dyb3VuZENvbG9yOiAndHJhbnNwYXJlbnQnLFxyXG4gIHNjYWxlOiAwXHJcbn0pO1xyXG5sZXQgdXNlcjFwaWN0dXJlID0gbmV3IExheWVyKHtcclxuICBzdXBlckxheWVyOiB1c2VyMSxcclxuICB3aWR0aDogMTA1LFxyXG4gIGhlaWdodDogMTA1LFxyXG4gIGltYWdlOiAnLi9pbWFnZXMvdXNlcjEucG5nJ1xyXG59KTtcclxudXNlcjFwaWN0dXJlLmNlbnRlclgoKTtcclxubGV0IHVzZXIxbmFtZSA9IG5ldyBMYXllcih7XHJcbiAgc3VwZXJMYXllcjogdXNlcjEsXHJcbiAgeTogMTI0LFxyXG4gIHdpZHRoOiAxMzAsXHJcbiAgaGVpZ2h0OiA2NSxcclxuICBpbWFnZTogJy4vaW1hZ2VzL3VzZXIxbmFtZS5wbmcnXHJcbn0pO1xyXG5cclxuZXhwb3J0IGxldCB1c2VyMiA9IG5ldyBMYXllcih7XHJcbiAgc3VwZXJMYXllcjogdXNlcnMsXHJcbiAgeDogMzE4LFxyXG4gIHk6IDI1NixcclxuICB3aWR0aDogMTA1LFxyXG4gIGhlaWdodDogMjAwLFxyXG4gIGJhY2tncm91bmRDb2xvcjogJ3RyYW5zcGFyZW50JyxcclxuICBzY2FsZTogMFxyXG59KTtcclxubGV0IHVzZXIycGljdHVyZSA9IG5ldyBMYXllcih7XHJcbiAgc3VwZXJMYXllcjogdXNlcjIsXHJcbiAgd2lkdGg6IDEwNSxcclxuICBoZWlnaHQ6IDEwNSxcclxuICBpbWFnZTogJy4vaW1hZ2VzL3VzZXIxLnBuZydcclxufSk7XHJcbnVzZXIycGljdHVyZS5jZW50ZXJYKCk7XHJcbmxldCB1c2VyMm5hbWUgPSBuZXcgTGF5ZXIoe1xyXG4gIHN1cGVyTGF5ZXI6IHVzZXIyLFxyXG4gIHk6IDEyNCxcclxuICB3aWR0aDogMTMwLFxyXG4gIGhlaWdodDogNjUsXHJcbiAgaW1hZ2U6ICcuL2ltYWdlcy91c2VyMW5hbWUucG5nJ1xyXG59KTsiLCIvLyBpbXBvcnQge2VhcnRoLCBjb25uZWN0QnV0dG9uLCBjb25uZWN0V3JhcHBlciwgY29ubmVjdFdyYXBwZXJCYWNrfSBmcm9tICcuL2xheWVycyc7XHJcbmltcG9ydCAqIGFzIGxheWVycyBmcm9tICcuL2xheWVycyc7XHJcblxyXG5sYXllcnMuZWFydGguc3RhdGVzLmFkZCgnY29ubmVjdFN0YXJ0Jywge1xyXG4gIHk6IFNjcmVlbi5oZWlnaHQgLSA0MjAsXHJcbn0pO1xyXG5sYXllcnMucGhvbmUuc3RhdGVzLmFkZCgnY29ubmVjdFN0YXJ0Jywge1xyXG4gIHk6IFNjcmVlbi5oZWlnaHQgLSA0NjAsXHJcbn0pO1xyXG5cclxubGF5ZXJzLmNvbm5lY3RXcmFwcGVyLnN0YXRlcy5hZGQoJ2V4cGFuZCcsIHtcclxuICBvcGFjaXR5OiAwXHJcbn0pO1xyXG5sYXllcnMudXNlcnMuc3RhdGVzLmFkZCgnZXhwYW5kJywge1xyXG4gIG9wYWNpdHk6IDFcclxufSk7XHJcbmxheWVycy5jbG9zZS5zdGF0ZXMuYWRkKCdleHBhbmQnLCB7XHJcbiAgb3BhY2l0eTogMVxyXG59KTtcclxubGF5ZXJzLnNpZ25hbC5zdGF0ZXMuYWRkKCdleHBhbmQnLCB7XHJcbiAgb3BhY2l0eTogMVxyXG59KTtcclxubGF5ZXJzLnRleHQuc3RhdGVzLmFkZCgnZXhwYW5kJywge1xyXG4gIG9wYWNpdHk6IDFcclxufSk7XHJcbmxheWVycy5jb25uZWN0QnV0dG9uLnN0YXRlcy5hZGQoJ2V4cGFuZCcsIHtcclxuICBvcGFjaXR5OiAxLFxyXG4gIHg6IDAsXHJcbiAgeTogMCxcclxuICB3aWR0aDogU2NyZWVuLndpZHRoLFxyXG4gIGhlaWdodDogU2NyZWVuLmhlaWdodCxcclxuICBib3JkZXJSYWRpdXM6IDBcclxufSk7XHJcbmxheWVycy5jb25uZWN0V3JhcHBlckJhY2suc3RhdGVzLmFkZCgnZXhwYW5kJywge1xyXG4gIG9wYWNpdHk6IDEsXHJcbiAgbWlkWDogU2NyZWVuLndpZHRoLzIsXHJcbiAgbWlkWTogU2NyZWVuLmhlaWdodC8yLFxyXG4gIHdpZHRoOiBTY3JlZW4ud2lkdGgqMi4xLFxyXG4gIGhlaWdodDogU2NyZWVuLndpZHRoKjIuMVxyXG59KTtcclxubGF5ZXJzLmNsb3NlLnN0YXRlcy5hZGQoJ2V4cGFuZCcsIHtcclxuICB4OiA3MixcclxuICB5OiA3MixcclxuICBvcGFjaXR5OiAxXHJcbn0pO1xyXG5cclxubGF5ZXJzLnVzZXJzLnN1YkxheWVycy5mb3JFYWNoKGZ1bmN0aW9uKGxheWVyKXtcclxuICBsYXllci5zdGF0ZXMuYWRkKCdmaW5kRGV2aWNlcycsIHtcclxuICAgIHNjYWxlOiAxXHJcbiAgfSk7XHJcbn0pO1xyXG5cclxubGF5ZXJzLnVzZXIxLnN0YXRlcy5hZGQoJ2Nvbm5lY3RSZXF1ZXN0Jywge1xyXG4gIG1pZFg6IFNjcmVlbi53aWR0aC8yLFxyXG4gIHk6IDUwXHJcbn0pO1xyXG5sYXllcnMudXNlcjEuc3RhdGVzLmFkZCgnY29ubmVjdFJlcXVlc3RIaWRlJywge1xyXG4gIHk6IDMwMCxcclxuICBvcGFjaXR5OiAwXHJcbn0pO1xyXG5sYXllcnMudXNlcjIuc3RhdGVzLmFkZCgnY29ubmVjdFJlcXVlc3QnLCB7XHJcbiAgbWlkWDogU2NyZWVuLndpZHRoLzIsXHJcbiAgeTogNTBcclxufSk7XHJcbmxheWVycy51c2VyMi5zdGF0ZXMuYWRkKCdjb25uZWN0UmVxdWVzdEhpZGUnLCB7XHJcbiAgeTogMzAwLFxyXG4gIG9wYWNpdHk6IDBcclxufSk7XHJcblxyXG5sYXllcnMudGV4dC5zdGF0ZXMuYWRkKHtcclxuICAnb3V0Jzoge1xyXG4gICAgeTogMjAwLFxyXG4gICAgb3BhY2l0eTogMFxyXG4gIH0sXHJcbiAgJ2luJzoge1xyXG4gICAgeTogMjUwLFxyXG4gICAgb3BhY2l0eTogMVxyXG4gIH1cclxufSk7XHJcblxyXG5sYXllcnMuc2lnbmFsTGluZTEuc3RhdGVzLmFkZCgnY29ubmVjdGluZycsIHtcclxuICByb3RhdGlvbjogNDgsXHJcbn0pO1xyXG5cclxubGF5ZXJzLnNpZ25hbExpbmUyLnN0YXRlcy5hZGQoJ2Nvbm5lY3RpbmcnLCB7XHJcbiAgcm90YXRpb246IDQzLjUsXHJcbn0pO1xyXG5cclxuIl19
