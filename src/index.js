(function() {
  'use strict';

  // Hide initial loader
  document.getElementById("initial-loader").style["display"] = "none";

  // Mount Elm
  var app = Elm.Main.embed(document.getElementById('main'));

  /*
   * Ports
   */

  // localStorage
  app.ports.localStorageSet.subscribe(function({ key, value }) {
    localStorage.setItem(key, value);
  });

  app.ports.localStorageGet.subscribe(function(key) {
    app.ports.localStorageReceive.send({ key: key, value: localStorage.getItem(key) });
  });

  app.ports.localStorageRemove.subscribe(function(key) {
    localStorage.removeItem(key);
  });

  // click an element
  app.ports.click.subscribe(function(id) {
    var el = document.getElementById(id);
    if (!!el && typeof el.click === "function") { el.click(); }
  });

  // listen to Ctrl+Enter
  document.addEventListener("keydown", function(ev) {
    if (ev.ctrlKey && ev.which == 13) { app.ports.ctrlEnter.send(null); }
  });
})();
