/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var pickFiles = require('broccoli-static-compiler');

var app = new EmberApp({
  vendorFiles: {
    // FIXME: torii needs full Handlebars for now. See https://github.com/ember-cli/ember-cli/pull/675
    'handlebars.js': {
      production: 'bower_components/handlebars/handlebars.js'
    }
  }
});

// Use `app.import` to add additional libraries to the generated
// output files.
//
// If you need to use different assets in different
// environments, specify an object as the first parameter. That
// object's keys should be the environment name and the values
// should be the asset to use in that environment.
//
// If the library that you are including contains AMD or ES6
// modules that you would like to import into your application
// please specify an object with the list of modules as keys
// along with the exports of each module as its value.

var sinon = pickFiles('bower_components/sinonjs-built/lib', {
  srcDir: '/',
  files: ['**/*.js'],
  destDir: '/assets'
});

app.import('bower_components/jquery-cookie/jquery.cookie.js');
app.import('bower_components/ember-fsm/dist/globals/ember-fsm.js');
app.import('bower_components/bootstrap-combobox/js/bootstrap-combobox.js');
app.import('bower_components/bootstrap-combobox/css/bootstrap-combobox.css');
app.import('bower_components/language-detector-wehlutyk/languageDetector.min.js');

module.exports = app.toTree(sinon);
