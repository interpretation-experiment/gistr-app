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
        lifecycle = this.get('lifecycle'),
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

      // Transition lifecycle state if possible
      var cycle = lifecycle.validateState();
      if (cycle.isComplete) {
        lifecycle.transitionUp();
      }

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
  profileValidationMap: {
    'registering': {
      'has-mothertongue': "Set your mothertongue"
    },
    'exp.training': {
      'tested-read-write-speed': "Test your reading and writing speeds",
      'tested-memory-span': "Test your memory span",
      'answered-questionnaire': "Fill in the general questionnaire"
    }
  },
  profileErrors: function() {
    var lifecycle = this.get('lifecycle'),
        validationMap = this.get('profileValidationMap'),
        errors = [];

    var validation = lifecycle.validateState(),
        state = validation.state;

    for (var error of validation.pending) {
      if (lifecycle.get('items')[state][error].route === 'profile') {
        errors.push(validationMap[state][error]);
      }
    }

    return errors;
  }.property('lifecycle.currentState'),
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
