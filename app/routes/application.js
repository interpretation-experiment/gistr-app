export default Ember.Route.extend({
  // FIXME[try promises]: untested because ran into problems. Try again later.
  setupController: function(controller, model) {
    // Starting the infinite loop in tests will make the tests fail
    if (!window.ENV.testing)
      controller.updateNetstatusLoop();
  }
});
