import Ember from 'ember';

export default Ember.Route.extend({
  model: function() {
    return this.store.find('sentence', '1');
  }
});

/*

// --- routes/play/read.js
  actions: {
    // No need to test this
    willTransition: function(transition) {
      this._willTransition(transition);
    },

    // No need to test this
    didTransition: function() {
      this._didTransition();
    }
  },

  _willTransition: function(transition) {
    this.controller.send('cancelCountdown');
  },

  _didTransition: function() {
    if (this.get('startCountdown')) {
      this._startCountdown(this.controllerFor('play/read'));
    }
  },

  startCountdown: true,

  _startCountdown: function(controller) {
    controller.send('startCountdown', this, function() {
      this.transitionTo('play.ok');
    });
  }

*/
