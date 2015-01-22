import Ember from 'ember';
import ApplicationRouteMixin from 'simple-auth/mixins/application-route-mixin';
import config from '../config/environment';

export default Ember.Route.extend(ApplicationRouteMixin, {
  // FIXME[try promises]: untested because ran into problems. Try again later.
  setupController: function(controller, model) {
    this._super(controller, model);

    // Starting the infinite loop in tests will make the tests fail
    if (config.environment !== 'test'){
      controller.updateNetstatusLoop();
    }
  }
});
