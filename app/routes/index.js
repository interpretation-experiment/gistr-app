import Ember from 'ember';

export default Ember.Route.extend({
  // TODO: test
  setupController: function(controller, model) {
    this._super(controller, model);
  },

  actions: {
    login: function() {
      var controller = this.controllerFor('index');
      this.get('session').open('spreadr', {
        username: controller.get('username'),
        password: controller.get('password')
      }).then(function() {
        controller.set('error', undefined);
        controller.set('username', undefined);
        controller.set('password', undefined);
      }, function(error) {
        var err = error.detail;
        if ('detail' in error) {
          err = error.detail;
        } else if ('non_field_errors' in error) {
          err = error.non_field_errors;
        } else {
          err = JSON.stringify(error);
        }
        controller.set('error', 'Oops! ' + err);
        controller.set('username', undefined);
        controller.set('password', undefined);
      });
    },

    logout: function() {
      this.get('session').close('spreadr');
    }
  }
});
