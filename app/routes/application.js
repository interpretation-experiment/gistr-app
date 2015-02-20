import Ember from 'ember';
import config from '../config/environment';

export default Ember.Route.extend({
  renderTemplate: function() {
    // Render default outlet
    this.render();
    // Render extra outlets for bootstrap tooltips
    var controller = this.controllerFor('tooltip-box');
    this.render("bs-tooltip-box", {
      outlet: "bs-tooltip-box",
      controller: controller,
      into: "application" // important when using at root level
    });
  },

  setupController: function(controller, model) {
    this._super(controller, model);

    // Starting the infinite loop in tests will make the tests fail
    if (config.environment !== 'test'){
      controller.sendStateEvent('check');
    }

    // See if we're logged in
    var self = this;
    this.get('session').fetch('spreadr').then(function() {
      self.send('loggedIn', self.get('session'));
    });
  },

  actions: {
    logout: function() {
      var self = this;
      this.get('session').close('spreadr').then(function() {
        self.transitionTo('index');
      });
    },
    loggedIn: function(session) {
      // Request a profile if we have none
      var profile = session.get('currentUser.profile');
      if (!profile) {
        this.store.createRecord('profile', {
          language: 'english'  // FIXME: language
        }).save();
      }
    }
  }
});
