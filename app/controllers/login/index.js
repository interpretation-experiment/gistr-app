import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  needs: ['profile'],
  growl: Ember.inject.service(),

  /*
   * Login form fields
   */
  username: null,
  password: null,
  errors: null,
  attemptedTransition: null,
  reset: function() {
    this.setProperties({
      username: null,
      password: null,
      errors: null,
      attemptedTransition: null,
    });
  },
  login: function() {
    var self = this, data = this.getProperties('username', 'password'),
        attemptedTransition = this.get('attemptedTransition');

    return this.get('session').open('spreadr', data).then(function() {
      self.reset();
      if (self.get('lifecycle').isAfter('registering')) {
        if (!Ember.isNone(attemptedTransition)) {
          attemptedTransition.retry();
        } else {
          self.transitionToRoute('index');
        }
      } else {
        self.get('growl').notice('Tell us about you!', 'We need you to fill in your profile');
        self.transitionToRoute('profile');
      }
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
    login: function(callback) {
      var promise = this.login();
      callback(promise);
    }
  }
});
