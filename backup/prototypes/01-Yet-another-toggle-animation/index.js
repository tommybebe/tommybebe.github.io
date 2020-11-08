'use strict';

// Original => https://dribbble.com/shots/2309834-Yet-another-toggle-animation

Framer.Defaults.Animation = {
  curve: "spring(300, 40, 0)"
};

let colors = {
  back: '#F3E5D3',
  toggleBackground: '#fefdff',
  toggleOn: '#7e86f9'
};

let wrapper = new Layer({
  width: 440,
  height: 340,
  backgroundColor: '#fff',
  borderRadius: 3 ,
  shadowX: 0,
  shadowY: 1,
  shadowBlur: 2,
  shadowSpread: 0,
  shadowColor: "rgba(0,0,0,0.07)"
});
wrapper.center();

let back = new Layer({
  width: 400,
  height: 300,
  backgroundColor: colors.back
});
back.center()

let toggle = new Layer({
  superLayer: back,
  width: 160,
  height: 83,
  backgroundColor: colors.toggleBackground,
  borderRadius: 45
});
toggle.center()

let buttonBefore = new Layer({
  superLayer: toggle,
  x: 8,
  y: 8,
  width: 68,
  height: 68,
  backgroundColor: colors.back,
  borderRadius: 68/2,
  shadowX: 1,
  shadowY: 3,
  shadowBlur: 8,
  shadowSpread: 3,
  shadowColor: "rgba(0,0,0,0.14)"
});

let button = new Layer({
  superLayer: toggle,
  x: 8,
  y: 8,
  width: 68,
  height: 68,
  backgroundColor: colors.back,
  borderRadius: 68/2
});

let buttonInner = new Layer({
  superLayer: button,
  width: button.width,
  height: button.height,
  backgroundColor: colors.toggleOn,
  opacity: 0
});

let line1 = new Layer({
  superLayer: button,
  width: 30,
  height: 4,
  rotation: 45,
  backgroundColor: colors.toggleBackground,
  borderRadius: 4,
});
line1.center();

let line2 = new Layer({
  superLayer: button,
  width: 30,
  height: 4,
  rotation: 315,
  backgroundColor: colors.toggleBackground,
  borderRadius: 4,
});
line2.center();


buttonBefore.states.add({
  on: {
    x: toggle.width - button.width - 8,
    opacity: 1
  },
  off: {
    x: 8,
    opacity: 0
  }
});

button.states.add({
  on: {
    x: toggle.width - button.width - 8
  },
  off: {
    x: 8
  }
});

buttonInner.states.add({
  on: {
    opacity: 1
  },
  off: {
    opacity: 0
  }
});

line1.states.add({
  on: {
    x: line1.x + 4,
    y: line2.y ,
    width: line1.width + 4,
    rotation: -45
  },
  off: {
    x: line1.x,
    y: line2.y,
    width: line1.width,
    rotation: 45,
  }
});
line2.states.add({
  on: {
    x: line2.x - 4,
    y: line2.y + 6,
    width: 17,
    rotation: 45
  },
  off: {
    x: line2.x,
    y: line2.y,
    width: line2.width,
    rotation: 315
  }
});

button.on(Events.Click, ()=>{
  button.states.next('on', 'off');
  buttonBefore.states.next('on', 'off');
  buttonInner.states.next('on', 'off');
  line1.states.next('on', 'off');
  line2.states.next('on', 'off');
});

button.states.next('on', 'off');
buttonBefore.states.next('on', 'off');
buttonInner.states.next('on', 'off');
line1.states.next('on', 'off');
line2.states.next('on', 'off');
