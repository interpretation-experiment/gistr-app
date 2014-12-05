import TracingRoute from '../tracing-route';

// TODO[after backend]: model should be recreated each time we enter here
export default TracingRoute.extend({
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
    this._super(transition);
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
});
