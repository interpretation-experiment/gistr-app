import Ember from 'ember';
import config from '../config/environment';

export default Ember.Route.extend({
  // FIXME[try promises]: untested because ran into problems. Try again later.
  setupController: function(controller, model) {
    this._super(controller, model);

    // Starting the infinite loop in tests will make the tests fail
    if (config.environment !== 'test'){
      controller.updateNetstatusLoop();
    }

    // See if we're logged in
    var self = this;
    this.get('session').fetch('spreadr').then(function() {
      self.send('loggedIn', self.get('session'));
    });
  },

  actions: {
    logout: function() {
      this.get('session').close('spreadr');
    },
    loggedIn: function(session) {
      var self = this;

      // Request a profile if we have none
      session.get('currentUser').then(function(user) {
        return user.get('profile');
      }).then(function(profile) {
        if (!profile) {
          self.store.createRecord('profile', {}).save();
        }
      });
    }
  }
});
