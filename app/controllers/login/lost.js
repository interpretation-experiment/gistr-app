import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import api from 'gistr/utils/api';


export default Ember.Controller.extend(SessionMixin, {
  /*
   * Login form fields
   */
  requesting: true,
  email: null,
  errors: null,
  reset: function() {
    this.setProperties({
      requesting: true,
      email: null,
      errors: null,
    });
  },
  resetPassword: function() {
    var self = this, email = this.get('email');

    return request(api('/rest-auth/password/reset/'), {
      type: 'POST',
      data: { email: email }
    }).then(function() {
      self.set('requesting', false);
    }, function(errors) {
      self.set('errors', errors.jqXHR.responseJSON || { __all__: errors.errorThrown });
    });
  },

  /*
   * Login actions
   */
  actions: {
    reset: function() {
      this.reset();
    },
    resetPassword: function(callback) {
      var promise = this.resetPassword();
      callback(promise);
    }
  }
});
