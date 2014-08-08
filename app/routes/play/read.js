import TracingRoute from 'appkit/routes/tracing-route';

// FIXME: model should be recreated each time we enter here
export default TracingRoute.extend({
  setupController: function(controller, sentence) {
    // FIXME: untested
    controller.set('model', sentence);
    if (!window.ENV.testing) {
      controller.send('startCountdown', this, function() {
        this.transitionTo('play.ok');
      });
    }
  },

  actions: {
    // FIXME: untested
    willTransition: function(transition) {
      this._willTransition(transition);
    }
  },

  // FIXME: untested
  _willTransition: function(transition) {
    this._super(transition);
    this.controller.send('cancelCountdown');
  }
});
