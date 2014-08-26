import TracingRoute from 'appkit/routes/tracing-route';

// FIXME: model should be recreated each time we enter here
export default TracingRoute.extend({
  setupController: function(controller, sentence) {
    controller.set('model', sentence);

    controller.send('startCountdown', this, function() {
      this.transitionTo('play.ok');
    });
  },

  actions: {
    // WONTFIX: Not unit-tested.
    // Testing this action needs a full-blown app,
    // because it triggers other events on the router
    willTransition: function(transition) {
      this._willTransition(transition);
    }
  },

  _willTransition: function(transition) {
    this._super(transition);
    this.controller.send('cancelCountdown');
  }
});
