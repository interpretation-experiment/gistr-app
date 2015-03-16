import Ember from 'ember';

import config from 'gistr/config/environment';


export default Ember.Route.extend({
  beforeModel: function(transition) {
    // Starting the infinite loop in tests will make the tests fail
    if (config.environment !== 'test'){
      this.controllerFor('application').sendStateEvent('check');
    }

    // See if we're logged in, and wait for the answer
    var self = this;
    return this.get('session').fetch('spreadr').then(function() {
      transition.send('loggedIn', self.get('session'));
    }, function() {});
  },

  actions: {
    logout: function() {
      var self = this;
      this.get('session').close('spreadr').then(function() {
        self.transitionTo('index');
      });
    },
    loggedIn: function(/*session*/) {
      // Do nothing
    }
  }
});
