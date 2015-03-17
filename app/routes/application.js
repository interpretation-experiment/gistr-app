import Ember from 'ember';

import config from 'gistr/config/environment';


export default Ember.Route.extend({
  lang: Ember.inject.service(),

  beforeModel: function(/*transition*/) {
    // Starting the infinite loop in tests will make the tests fail
    if (config.environment !== 'test'){
      this.controllerFor('application').sendStateEvent('check');
    }

    // See if we're logged in, populate language support
    var self = this;
    return Ember.RSVP.all([
      self.get('session').fetch('spreadr').then(null, function() {}),
      self.get('lang').populate()
    ]);
  },

  actions: {
    logout: function() {
      var self = this;
      this.get('session').close('spreadr').then(function() {
        self.transitionTo('index');
      });
    }
  }
});
