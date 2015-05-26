import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import api from 'gistr/utils/api';


export default Ember.Controller.extend(SessionMixin, {
  queryParams: ['uid', 'token'],
  uid: null,
  token: null,

  resetting: true,
  resetted: false,
  new_password1: null,
  new_password2: null,
  errors: null,
  resetInput: function() {
    this.setProperties({
      resetting: true,
      resetted: false,
      new_password1: null,
      new_password2: null,
      errors: null,
    });
  },
  reset: function() {
    this.resetInput();
  },
  upload: function() {
    var self = this,
        new_password1 = this.get('new_password1'),
        new_password2 = this.get('new_password2'),
        errors = {},
        data = this.getProperties('new_password1', 'new_password2', 'uid', 'token');

    // The API for password reset is really quiet on errors,
    // and even reports errors on the token when really it's
    // the passwords that are bad (e.g. mismatching).
    // So we do our own checks here.
    if (new_password1 !== new_password2) {
      errors.non_field_errors = "Passwords don't match";
    }
    if (Ember.isNone(new_password1) || new_password1.length === 0) {
      errors.new_password1 = "Password can't be empty"
    }
    if (!Ember.isNone(new_password1) && new_password1.length < 6) {
      errors.new_password1 = "Password must be at least 6 characters"
    }

    if (Object.keys(errors).length > 0) {
      this.set('errors', errors);
      return new Ember.RSVP.Promise(function(resolve) { resolve(); });
    }

    return request(api('/rest-auth/password/reset/confirm/'), {
      type: 'POST',
      data: data
    }).then(function() {
      return self.get('session').close('spreadr');
    }).then(function() {
      self.set('resetted', true);
      self.set('resetting', false);
    }, function(errors) {
      var jqErrors = errors.jqXHR.responseJSON || { __all__: errors.errorThrown };
      if (!('new_password1' in jqErrors) && !('new_password2' in jqErrors)) {
        // Unrecoverable error
        self.set('resetting', false);
      } else {
        self.set('errors', jqErrors);
      }
    });
  },
  actions: {
    upload: function(callback) {
      callback(this.upload());
    },
    reset: function() {
      this.reset();
    }
  }
});
