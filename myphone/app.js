setTimeout(function(){
  CoffeeScript.load("app.coffee")

  Framer.Device = new Framer.DeviceView();
  Framer.Device.setupContext();
  Framer.Device.deviceType = "iphone-6-gold"
}, 1);

