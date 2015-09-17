setTimeout(function(){
  
  var script = './app.coffee';

  var routes = {
    intro: [
      '0.2.1',
      '0.2.0',
      '0.1.0',
    ],
    optimize: [
      '0.3.0',
      '0.2.1',
    ],
    fileOpt: [
      '0.1.0'
    ],
    appManage: [
      '0.1.0'
    ]
  }
  var buttons = [];

  function purge(d) {
    var a = d.attributes, i, l, n;
    if (a) {
        for (i = a.length - 1; i >= 0; i -= 1) {
            n = a[i].name;
            if (typeof d[n] === 'function') {
                d[n] = null;
            }
        }
    }
    a = d.childNodes;
    if (a) {
        l = a.length;
        for (i = 0; i < l; i += 1) {
            purge(d.childNodes[i]);
        }
    }
  }

  if(window.location.hash){
    Framer.Device = new Framer.DeviceView();
    Framer.Device.setupContext();
    CoffeeScript.load('./pages/' + window.location.hash.replace('#', '') + '.coffee');
  } else {

    Object.keys(routes).forEach(function(route){

      var button = document.createElement("li");
      var text = route + '.' + routes[route][0];
      var textNode = document.createTextNode(text);
      var dom = document.getElementById('links');

      button.appendChild(textNode);
      dom.appendChild(button);
      buttons.push(button);

      button.addEventListener('click', function(){

        Framer.Device = new Framer.DeviceView();
        Framer.Device.setupContext();

        purge(dom);
        buttons.forEach(function(button){
          button.remove();
        });
        CoffeeScript.load('./pages/' + text + '.coffee');
      });
    });
  }
}, 1);

