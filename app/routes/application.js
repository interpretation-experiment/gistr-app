import Ember from 'ember';


export default Ember.Route.extend({
  lang: Ember.inject.service(),
  shaping: Ember.inject.service(),

  beforeModel: function(/*transition*/) {
    // See if we're logged in, populate language support
    var self = this;
    return Ember.RSVP.all([
      self.get('session').fetch('spreadr').catch(function() {}),
      self.get('lang').populate(),
      self.get('shaping').populate()
    ]);
  },

  actions: {
    logout: function(callback) {
      var self = this, promise;
      promise = this.get('session').close('spreadr').then(function() {
        self.transitionTo('index');
      });
      callback(promise);
    }
  }
});
