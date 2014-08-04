import TracingRoute from 'appkit/routes/tracing-route';

// FIXME: model should be recreated each time we enter here
export default TracingRoute.extend({
  setupController: function(controller, sentence) {
    // FIXME: untested
    controller.set('model', sentence);
    if (!window.ENV.testing) {
      controller.startCountdown(this, function() {
        this.transitionTo('play.ok');
      });
    }
  }
});
