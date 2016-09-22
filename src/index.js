'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');

// Require index.html so it gets copied to dist
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
var app = Elm.Main.embed(mountNode);

// Ports
app.ports.localStorageSet.subscribe(function({ key, value }) {
  localStorage.setItem(key, value);
});

app.ports.localStorageGet.subscribe(function(key) {
  app.ports.localStorageReceive.send({ key: key, value: localStorage.getItem(key) });
});

app.ports.localStorageRemove.subscribe(function(key) {
  localStorage.removeItem(key);
});
