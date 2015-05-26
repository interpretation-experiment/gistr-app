import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  growl: Ember.inject.service(),
  emails: Ember.computed.alias('currentUser.emails'),

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
  email: null,
  errors: null,
  isUploading: null,
  resetInput: function() {
    this.setProperties({
      email: null,
      errors: null,
      isUploading: null,
    });
    Ember.$('input').blur();
  },
  upload: function() {
    var self = this,
        growl = this.get('growl'),
        data = this.getProperties('email');

    this.set('isUploading', true);
    this.set('justSaved', false);

    return this.get('store').createRecord('email', data).save().then(function() {
      self.set('justSaved', true);
      growl.info("Verification email",
                 `A verification email has been sent to ` +
                 `<strong>${data.email}</strong>, please ` +
                 `follow the instructions in it`);
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
    upload: function(callback) {
      callback(this.upload());
    },
    setPrimary: function(email) {
      var oldPrimary = this.get('emails').filter(function(e) {
        return e.get('primary');
      }).objectAt(0);

      oldPrimary.set('isChanging', true);
      email.set('primary', true).save().then(function() {
        oldPrimary.reload();
        oldPrimary.set('isChanging', false);
      });
    },
    remove: function(email) {
      if (this.get('emails.length') <= 1 || !email.get('primary')) {
        email.destroyRecord();
      } else {
        this.get('emails').filter(function(e) {
          return e !== email;
        })
        .objectAt(0)
        .set('primary', true)
        .save().then(function() {
          email.destroyRecord();
        });
      }
    }
  }
});
