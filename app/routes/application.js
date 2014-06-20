export default Ember.Route.extend({
  setupController: function(controller, model) {
    // Starting the infinite loop in tests will make the tests fail
    if (!window.ENV.testing)
      controller.updateNetstatusLoop();
  }
});
