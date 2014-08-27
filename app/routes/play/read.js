import TracingRoute from 'appkit/routes/tracing-route';

// TODO[after backend]: model should be recreated each time we enter here
export default TracingRoute.extend({
  setupController: function(controller, sentence) {
    this._super(controller, sentence);
    if (this.get('startCountdown')) {
      this._startCountdown(controller);
    }
  },

  actions: {
    // Testing this action needs a full-blown app,
    // because it triggers other events on the router.
    // So it's not unit-tested, but is covered by acceptance tests.
    willTransition: function(transition) {
      this._willTransition(transition);
    }
  },

  _willTransition: function(transition) {
    this._super(transition);
    this.controller.send('cancelCountdown');
  },

  startCountdown: true,

  _startCountdown: function(controller) {
    controller.send('startCountdown', this, function() {
      this.transitionTo('play.ok');
    });
  }
});
