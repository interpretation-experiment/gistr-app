import TracingRoute from 'appkit/routes/tracing-route';

// FIXME: model should be recreated each time we enter here
export default TracingRoute.extend({
  setupController: function(controller, sentence) {
    controller.set('model', sentence);

    var that = this;
    Ember.run(function() {
      controller.send('startCountdown', that, function() {
        this.transitionTo('play.ok');
      });
    });
  },

  actions: {
    // FIXME: untested
    willTransition: function(transition) {
      this._willTransition(transition);
    }
  },

  _willTransition: function(transition) {
    this._super(transition);
    this.controller.send('cancelCountdown');
  }
});
