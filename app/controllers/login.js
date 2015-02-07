import Ember from 'ember';
import SessionMixin from './session';

export default Ember.ObjectController.extend(SessionMixin, {
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
  loginText: function() {
    if (this.get('session').get('isWorking')) {
      return 'Signing you in...';
    } else {
      return 'Sign in';
    }
  }.property('session.isWorking'),
  actions: {
    reset: function() {
      this.reset();
    },
    login: function() {
      var self = this, data = this.getProperties('username', 'password');

      this.get('session').open('spreadr', data).then(function() {
        self.send('loggedIn', self.get('session'));
        self.reset();
        self.transitionToRoute('index');
      }, function(errors) {
        self.set('errors', errors);
      });
    }
  }
});
