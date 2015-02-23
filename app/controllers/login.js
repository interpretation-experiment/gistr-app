import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.ObjectController.extend(SessionMixin, {
  /*
   * Login form fields
   */
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
  login: function() {
    var self = this, data = this.getProperties('username', 'password');

    this.get('session').open('spreadr', data).then(function() {
      self.send('loggedIn', self.get('session'));
      self.reset();
      self.transitionToRoute('index');
    }, function(errors) {
      self.set('errors', errors);
    });
  },

  /*
   * Login actions
   */
  actions: {
    reset: function() {
      this.reset();
    },
    login: function() {
      this.login();
    }
  }
});
