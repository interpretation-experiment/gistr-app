import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  /*
   * Global state and reset
   */
  justSaved: Ember.Object.create({
    password: false,
    username: false,
  }),
  watchSaved: function() {
    if (this.get('justSaved.password')) {
      Ember.run.later(this, function() {
        this.set('justSaved.password', false);
      }, 2000);
    }
    if (this.get('justSaved.username')) {
      Ember.run.later(this, function() {
        this.set('justSaved.username', false);
      }, 2000);
    }
  }.observes('justSaved.password', 'justSaved.username'),
  reset: function() {
    this.resetInput();
    this.set('justSaved.password', false);
    this.set('justSaved.username', false);
  },

  /*
   * Profile form fields, state, and upload
   */
  username: null,
  errors: null,
  isUploading: null,
  resetInput: function() {
    this.setProperties({
      username: this.get('currentUser.username'),
      errors: null,
      isUploading: null,
    });
    Ember.$('input').blur();
  },
  uploadUser: function() {
    var self = this, data = this.getProperties('username'),
        user = this.get('currentUser');

    this.set('isUploading', true);
    this.set('justSaved.username', false);

    return user.setProperties(data).save().then(function() {
      self.set('justSaved.username', true);
      self.resetInput();
    }, function(error) {
      self.set('errors', error.errors);
    }).finally(function() {
      self.set('isUploading', false);
    });
  },
  actions: {
    reset: function() {
      this.reset();
    },
    uploadUser: function(callback) {
      callback(this.uploadUser());
    }
  }
});
