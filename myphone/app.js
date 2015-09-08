setTimeout(function(){
  
  Framer.Device = new Framer.DeviceView();
  Framer.Device.setupContext();
  Framer.Device.deviceType = "iphone-6-gold"

  var script = './app.coffee';

  if(window.location.hash){
    script = script.replace('app', window.location.hash.replace('#', ''));
  }
  CoffeeScript.load(script);

}, 1);

