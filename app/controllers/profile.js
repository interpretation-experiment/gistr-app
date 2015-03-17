import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(SessionMixin, {
  lang: Ember.inject.service(),

  /*
   * Global state and reset
   */
  justSaved: null,
  watchSaved: function() {
    if (this.get('justSaved')) {
      Ember.run.later(this, function() {
        this.set('justSaved', null);
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

    profile.save().then(function() {
      self.set('justSaved', true);
      self.resetInput();

      if (!!attemptedTransition) {
        attemptedTransition.retry();
      }
    }, function(error) {
      self.set('isUploading', false);
      self.set('errors', error.errors);
    });
  },

  /*
   * Profile completeness
   */
  isProfileIncomplete: function() {
    return this.get('profileErrors.length') > 0;
  }.property('profileErrors.length', 'session.isWorking'),
  profileErrors: function() {
    if (!this.get('session.isWorking') && !this.get('currentProfile')) {
      return ['Set your mothertongue'];
    } else {
      return [];
    }
  }.property('currentProfile'),

  /*
   * Profile actions
   */
  actions: {
    reset: function() {
      this.reset();
    },
    uploadProfile: function() {
      this.uploadProfile();
    },
    toggleOtherInfo: function() {
      this.toggleProperty('showOtherInfo');
    },
    toggleBilingualInfo: function() {
      this.toggleProperty('showBilingualInfo');
    }
  }
});
