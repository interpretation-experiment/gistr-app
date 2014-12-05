import Ember from 'ember';
import Resolver from 'ember/resolver';
import loadInitializers from 'ember/load-initializers';
import config from './config/environment';

Ember.MODEL_FACTORY_INJECTIONS = true;

var App = Ember.Application.extend({
  modulePrefix: config.modulePrefix,
  podModulePrefix: config.podModulePrefix,
  Resolver: Resolver,
  ready: function() {
    if (config.environment !== 'production') {
      Ember.Logger.log("Non-production environment -> globalizing devTools");
      this.devTools.globalize();
    }
  }
});

loadInitializers(App, config.modulePrefix);

export default App;
