import Ember from 'ember';

export default Ember.ObjectController.extend({
  username: null,
  password: null,
  errors: null,
  reset: function() {
    this.setProperties({
      username: null,
      password: null,
      errors: null,
    });
  },
  actions: {
    login: function() {
      var self = this, data = this.getProperties('username', 'password');

      this.get('session').open('spreadr', data).then(function(authorization) {
        self.reset();
        self.transitionToRoute('index');
      }, function(errors) {
        self.set('errors', errors);
      });
    }
  }
});
