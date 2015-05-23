import Ember from 'ember';
import { request } from 'ic-ajax';

import SessionMixin from 'gistr/mixins/session';
import api from 'gistr/utils/api';


export default Ember.Controller.extend(SessionMixin, {
  /*
   * Global state and reset
   */
  justSaved: false,
  watchSaved: function() {
    if (this.get('justSaved')) {
      Ember.run.later(this, function() {
        this.set('justSaved', false);
      }, 2000);
    }
  }.observes('justSaved'),
  reset: function() {
    this.resetInput();
    this.set('justSaved', false);
  },

  /*
   * Form fields, state, and upload
   */
  old_password: null,
  new_password1: null,
  new_password2: null,
  errors: null,
  isUploading: null,
  resetInput: function() {
    this.setProperties({
      old_password: null,
      new_password1: null,
      new_password2: null,
      errors: null,
      isUploading: null,
    });
    Ember.$('input').blur();
  },
  upload: function() {
    var self = this,
        username = this.get('currentUser.username'),
        data = this.getProperties('old_password', 'new_password1', 'new_password2');

    this.set('isUploading', true);
    this.set('justSaved', false);

    return request(api('/rest-auth/password/change/'), {
      type: 'POST',
      data: data
    }).then(function() {
      return self.get('session').close('spreadr');
    }).then(function() {
      return self.get('session').open('spreadr', {
        username: username,
        password: data.new_password1
      });
    }).then(function() {
      self.set('justSaved', true);
      self.resetInput();
    }, function(errors) {
      self.set('errors', errors.jqXHR.responseJSON || { __all__: errors.errorThrown });
    }).finally(function() {
      self.set('isUploading', false);
    });
  },
  actions: {
    reset: function() {
      this.reset();
    },
    upload: function(callback) {
      callback(this.upload());
    }
  }
});
