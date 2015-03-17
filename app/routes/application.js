import Ember from 'ember';

import config from 'gistr/config/environment';


export default Ember.Route.extend({
  lang: Ember.inject.service(),

  beforeModel: function(/*transition*/) {
    // See if we're logged in, populate language support
    var self = this;
    return Ember.RSVP.all([
      self.get('session').fetch('spreadr').catch(function() {}),
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
