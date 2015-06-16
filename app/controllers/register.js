import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import api from 'gistr/utils/api';


export default Ember.Controller.extend(SessionMixin, {
  growl: Ember.inject.service(),

  /*
   * Registration form fields, state, and upload
   */
  username: null,
  email: null,
  password1: null,
  password2: null,
  prolificId: null,
  errors: null,
  isRegistering: false,
  reset: function() {
    this.setProperties({
      username: null,
      email: null,
      password1: null,
      password2: null,
      prolificId: null,
      errors: null,
      isRegistering: false,
    });
  },
  register: function() {
    var self = this,
        growl = this.get('growl'),
        data = this.getProperties('username', 'email', 'password1', 'password2');
    this.set('isRegistering', true);

    return request(api('/rest-auth/registration/'), {
      type: 'POST',
      data: data
    }).then(function() {
      return self.get('session').open('spreadr', {
        username: data.username,
        password: data.password1
      });
    }).then(function() {
      self.reset();
      if (!Ember.isNone(data.email) && data.email.length > 0) {
        growl.info("Verification email",
                   `A verification email has been sent to ` +
                   `<strong>${data.email}</strong>, please ` +
                   `follow the instructions in it`);
      }
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
    register: function(callback) {
      callback(this.register());
    }
  }
});
