import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  lang: Ember.inject.service(),

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
    this.setProperties({
      justSaved: null,
    });
  },

  /*
   * Profile form fields, state, and upload
   */
  mothertongue: null,
  errors: null,
  isUploading: null,
  attemptedTransition: null,
  showOtherInfo: false,
  showBilingualInfo: false,
  resetInput: function() {
    this.setProperties({
      mothertongue: this.get('currentProfile.mothertongue'),
      errors: null,
      isUploading: null,
      attemptedTransition: null,
      showOtherInfo: false,
      showBilingualInfo: false,
    });
  },
  uploadProfile: function() {
    var self = this, data = this.getProperties('mothertongue'),
        attemptedTransition = this.get('attemptedTransition'),
        profile = this.get('currentProfile');

    this.set('isUploading', true);
    this.set('justSaved', false);

    if (!profile) {
      // Create a profile
      profile = this.get('store').createRecord('profile', data);
    } else {
      // Update our existing profile
      profile.setProperties(data);
    }

    return profile.save().then(function() {
      self.set('justSaved', true);
      self.resetInput();

      if (!!attemptedTransition) {
        attemptedTransition.retry();
      }
    }, function(error) {
      self.set('errors', error.errors);
    }).finally(function() {
      self.set('isUploading', false);
    });
  },

  /*
   * Profile completeness
   */
  profileErrors: function() {
    if (this.get('session.isWorking')) {
      return [];
    }

    var errors = [];
    if (!this.get('currentProfile')) {
      errors.push('Set your mothertongue');
    }

    return errors;
  }.property('currentProfile'),
  isProfileIncomplete: Ember.computed.notEmpty('profileErrors'),

  /*
   * Profile actions
   */
  actions: {
    reset: function() {
      this.reset();
    },
    uploadProfile: function(callback) {
      callback(this.uploadProfile());
    },
    toggleOtherInfo: function() {
      this.toggleProperty('showOtherInfo');
    },
    toggleBilingualInfo: function() {
      this.toggleProperty('showBilingualInfo');
    }
  }
});
