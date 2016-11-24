'use strict';

// Require index.html so it gets copied to dist
require('./index.html');

// Mount Elm
var Elm = require('./Main.elm');
var app = Elm.Main.embed(document.getElementById('main'));

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
