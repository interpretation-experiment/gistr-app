import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import api from 'gistr/utils/api';


export default Ember.Controller.extend(SessionMixin, {
  /*
   * Registration form fields, state, and upload
   */
  username: null,
  password1: null,
  password2: null,
  errors: null,
  isRegistering: false,
  reset: function() {
    this.setProperties({
      username: null,
      password1: null,
      password2: null,
      errors: null,
      isRegistering: false
    });
  },
  register: function() {
    var self = this, data = this.getProperties('username', 'password1', 'password2');
    this.set('isRegistering', true);

    request(api('/rest-auth/registration/'), {
      type: 'POST',
      data: data
    }).then(function() {
      return self.get('session').open('spreadr', {
        username: data.username,
        password: data.password1
      });
    }).then(function() {
      self.reset();
      self.transitionToRoute('profile');
    }, function(errors) {
      self.set('errors', errors.jqXHR.responseJSON || { __all__: errors.errorThrown });
    }).finally(function() {
      self.set('isRegistering', false);
    });
  },

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
