Framer.Device = new Framer.DeviceView();
Framer.Device.setupContext();
Framer.Device.deviceType = "iphone-6-gold";
Framer.Defaults.Animation = { curve: "spring(300,30,0)" };
const color = {
  background: '#f4f4f4',
  connectButton: '#fff',
  connectButtonText: '#0091ea',
  connectBack: '#0091ea',
  signal: '#00a2f4'
};

let background = new BackgroundLayer({
  backgroundColor: color.background
});

export let connectButton = new Layer({
  width: 480,
  height: 80,
  backgroundColor: 'transparent',
  force2d: true,
  shadowY: 3,
  shadowBlur: 12,
  shadowColor: "rgba(0,0,0,0.2)",
  borderRadius: 12

});
connectButton.center();

export let connectWrapper = new Layer({
  superLayer: connectButton,
  width: 480,
  height: 80,
  opacity: 1,
  backgroundColor: color.connectButton,
});
connectWrapper.center();

let connectButtonText = new Layer({
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

export let connectWrapperBack = new Layer({
  superLayer: connectButton,
  width: 40,
  height: 40,
  backgroundColor: color.connectButtonText,
  opacity: 0,
  borderRadius: 3000
});
connectWrapperBack.center();

export let signal = new Layer({
  superLayer: connectButton,
  midX: Screen.width/2,
  y: 200,
  // width: Screen.height*1.3,
  // height: Screen.height*1.3,
  width: 900,
  height: 900,
  rotation: 222,
  opacity: 0,
  backgroundColor: 'transparent'
});

export let signalWrapper = new Layer({
  superLayer: signal,
  midX: 0,
  midY: 0,
  width: signal.width,
  height: signal.height,
  scale: 2,
  backgroundColor: 'transparent',
  borderRadius: signal.height
});

export let signalLine1 = new Layer({
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
export let signalLine2 = new Layer({
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

export let phone = new Layer({
  superLayer: connectButton,
  midX: Screen.width/2,
  y: Screen.height,
  width: 250,
  height: 426,
  image: './images/device.png',
  originY: 1.2
});

export let earth = new Layer({
  superLayer: connectButton,
  y: Screen.height,
  width: Screen.width,
  height: 466*3,
  backgroundColor: 'transparent',
  scale: 1.05
});

export let cloud1 = new Layer({
  superLayer: earth,
  y: 95,
  width: Screen.width,
  height: 295,
  image: './images/clouds.png'
});

let land = new Layer({
  superLayer: earth,
  width: Screen.width,
  height: 466,
  image: './images/earth.png'
});
land.centerX();

export let cloud2 = new Layer({
  superLayer: earth,
  y: 120,
  width: Screen.width,
  height: 400,
  image: './images/clouds.png'
});

export let close = new Layer({
  superLayer: connectButton,
  x: -39,
  y: -39,
  width: 39,
  height: 39,
  image: './images/close.png',
  opacity: 0,
});

export let text = new Layer({
  y: 250,
  width: 380,
  height: 48,
  html: '<h1>Waiting for connect..</h1>',
  backgroundColor: 'transparent',
  opacity: 0
})
text.centerX();

export let users = new Layer({
  y: 300,
  width: Screen.width,
  height: 500,
  backgroundColor: 'transparent',
  opacity: 0
});

export let user1 = new Layer({
  superLayer: users,
  x: 60,
  y: 112,
  width: 105,
  height: 200,
  backgroundColor: 'transparent',
  scale: 0
});
let user1picture = new Layer({
  superLayer: user1,
  width: 105,
  height: 105,
  image: './images/user1.png'
});
user1picture.centerX();
let user1name = new Layer({
  superLayer: user1,
  y: 124,
  width: 130,
  height: 65,
  image: './images/user1name.png'
});

export let user2 = new Layer({
  superLayer: users,
  x: 318,
  y: 256,
  width: 105,
  height: 200,
  backgroundColor: 'transparent',
  scale: 0
});
let user2picture = new Layer({
  superLayer: user2,
  width: 105,
  height: 105,
  image: './images/user1.png'
});
user2picture.centerX();
let user2name = new Layer({
  superLayer: user2,
  y: 124,
  width: 130,
  height: 65,
  image: './images/user1name.png'
});