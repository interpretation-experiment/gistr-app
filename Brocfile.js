/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var pickFiles = require('broccoli-static-compiler');

var app = new EmberApp();

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

var glyphicons = pickFiles('bower_components/bootstrap/dist/fonts', {
  srcDir: '/',
  destDir: '/fonts'
});

app.import('bower_components/jquery-cookie/jquery.cookie.js');
app.import('bower_components/ember-fsm/dist/globals/ember-fsm.js');
app.import('bower_components/bootstrap/dist/css/bootstrap.css');

module.exports = app.toTree([sinon, glyphicons]);
