(function() {
  'use strict';

  // Hide initial loader
  document.getElementById("initial-loader").style["display"] = "none";

  // Mount Elm
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
})();
