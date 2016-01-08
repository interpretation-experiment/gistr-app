/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var Funnel = require('broccoli-funnel');
var env = EmberApp.env();
var isProductionLikeBuild = ['production', 'staging'].indexOf(env) > -1;

var app = new EmberApp({
  fingerprint: {
    enabled: isProductionLikeBuild,
    prepend: '//d1zez0cfifq2rx.cloudfront.net/',
    generateAssetMap: true
  },
  sourcemaps: { enabled: !isProductionLikeBuild, },
  minifyCSS: { enabled: isProductionLikeBuild },
  minifyJS: { enabled: isProductionLikeBuild },

  tests: process.env.EMBER_CLI_TEST_COMMAND || !isProductionLikeBuild,
  hinting: process.env.EMBER_CLI_TEST_COMMAND || !isProductionLikeBuild,

  vendorFiles: {
    'ember.js': {
      staging:  'bower_components/ember/ember.prod.js'
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

var glyphicons = new Funnel('bower_components/bootstrap/dist/fonts', {
  srcDir: '/',
  destDir: '/fonts'
});

app.import('bower_components/jquery.easy-pie-chart/dist/jquery.easypiechart.js');

app.import('bower_components/ember-fsm/dist/globals/ember-fsm.js');

app.import('bower_components/bootstrap/dist/js/bootstrap.js');
app.import('bower_components/bootstrap/dist/css/bootstrap.css');

app.import('bower_components/bootstrap-tokenfield/dist/bootstrap-tokenfield.js');
app.import('bower_components/bootstrap-tokenfield/dist/css/bootstrap-tokenfield.css');

app.import('bower_components/pnotify/pnotify.core.js');
app.import('bower_components/pnotify/pnotify.core.css');
app.import('bower_components/pnotify/pnotify.buttons.js');
app.import('bower_components/pnotify/pnotify.buttons.css');

app.import('bower_components/d3/d3.js');

app.import('bower_components/google-diff-match-patch/diff_match_patch.js');

module.exports = app.toTree(glyphicons);
