import * as layers from './layers';
import './states';
import connector from './connector';

function scene (state, option) {
  Framer.CurrentContext._layerList.forEach(function(layer){
    if(layer._states && layer._states._orderedStates.indexOf(state) >= 0){
      layer.states.switch(state, option);
    }
  });
}

let earthRollingToggle = true;

function earthRolling(timestamp) {
  let r1 = Math.cos(timestamp/1000)*5;
  let r2 = Math.sin(timestamp/1000)*5;
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
      x: r2*5
    }
  });
  layers.phone.animate({
    properties: {
      rotation: r1*.3
    }
  });
  if(earthRollingToggle) window.requestAnimationFrame(earthRolling);
}
let earthRollingStart = ()=> {
  earthRollingToggle = true;
  window.requestAnimationFrame(earthRolling);
}
let earthRollingStop = ()=> {
  earthRollingToggle = false;
  setTimeout(function(){
    [layers.earth, layers.cloud1, layers.cloud2].forEach(function(l){
      l.animate({
        properties: {
          rotation: 0
        }
      });
    });
  }, 100);
}


class Wave {
  constructor(parent) {
    this.wave1 = new Layer({
      superLayer: parent,
      midX: parent.height/2,
      midY: parent.height/2,
      width: parent.width,
      height: parent.height,
      scale: 0,
      backgroundColor: '#00a2f4',
      borderRadius: parent.height
    });
    this.wave2 = new Layer({
      superLayer: parent,
      midX: parent.height/2,
      midY: parent.height/2,
      width: parent.width,
      height: parent.height,
      scale: this.wave1.scale*0.6,
      backgroundColor: '#0091ea',
      borderRadius: parent.height
    });
  }
  move(){
    this.wave1.animate({
      properties: {
        scale: 1.1
      },
      time: 5,
      curve: "cubic-bezier(.28,.36,.91,.57)"
    });
    Utils.delay(0.2, ()=>{
      this.wave2.animate({
        properties: {
          scale: 1
        },
        time: 5,
        curve: "cubic-bezier(.28,.36,.91,.57)"
      });
      this.wave2.on(Events.AnimationEnd, ()=>{
        this.end();
      });
    });
  }
  end(){
    this.wave1.destroy();
    this.wave2.destroy();
  }
}

function waveStart(){
  let wave = new Wave(layers.signalWrapper);
  wave.move();
  Utils.delay(1.4, ()=>{
    if(waveState) waveStart();
  });
}

function waveStop(){
  waveState = false;
}

var waveState = false;

layers.connectWrapper.on(Events.Click, function(){
  Utils.delay(0.3, function(){
    scene('expand');
  });
  earthRollingStart();
  waveState = true;
  waveStart();
  Utils.delay(0.7, function(){
    scene('connectStart', { time: 0.4, curve: "cubic-bezier(.9,.08,.44,.97)" });
  });
  Utils.delay(1.8, function(){
    scene('findDevices', { time: 0.3, curve: "spring(200, 20, 0)" });
  });
});

layers.close.on(Events.Click, ()=>{
  scene('default');
  waveStop();
  console.log(arguments);
});

let android = require('androidRipple');
layers.connectButton.on(Events.Click, android.ripple);

layers.users.subLayers.forEach(function(user){
  user.on(Events.TouchStart, function(e, layer){
    layer.animate({
      properties: {
        scale: 1.2
      }
    })
  });
  user.on(Events.TouchEnd, function(e, layer){
    layers.text.states.switch('out', { time: 0.1 });
    Utils.delay(0.3, ()=>{
      layers.text.html = '<h1>Connecting...</h1>'
      layers.text.states.switch('in', { time: 0.1 });
    });
    layer.animate({
      properties: {
        scale: 1
      }
    });
    user.states.switch('connectRequest');
    layers.users.subLayers.forEach((sub)=>{
      if(sub !== user){
        sub.states.switch('connectRequestHide');
      }
    });
    Utils.delay(0.5, ()=>{
      scene('connecting');
    });
  });
});