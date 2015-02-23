import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import config from 'gistr/config/environment';


export default Ember.ObjectController.extend(SessionMixin, {
  /*
   * Registration form fields, state, and upload
   */
  username: null,
  password1: null,
  password2: null,
  errors: null,
  isRegistering: null,
  reset: function() {
    this.setProperties({
      username: null,
      password1: null,
      password2: null,
      errors: null,
      isRegistering: null
    });
  },
  register: function() {
    var self = this, data = this.getProperties('username', 'password1', 'password2');
    this.set('isRegistering', true);

    new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        type: 'POST',
        dataType: 'json',
        url: config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + '/rest-auth/registration/',
        data: data,
        success: Ember.run.bind(null, resolve),
        error: Ember.run.bind(null, reject)
      });
    }).then(function() {
      return self.get('session').open('spreadr', {
        username: data.username,
        password: data.password1
      });
    }).then(function() {
      self.send('loggedIn', self.get('session'));
      self.reset();
      self.transitionToRoute('index');
    }, function(xhr, error, errorThrown) {
      self.set('isRegistering', false);
      self.set('errors', xhr.responseJSON || { __all__: errorThrown });
    });
  },
  // FIXME: move to view
  registerText: function() {
    if (this.get('isRegistering')) {
      return 'Signing you up...';
    } else {
      return 'Sign up';
    }
  }.property('isRegistering'),

  /*
   * Registration actions
   */
  actions: {
    reset: function() {
      this.reset();
    },
    register: function() {
      this.register();
    }
  }
});
