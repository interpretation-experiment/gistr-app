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
  showOtherInfo: false,
  showBilingualInfo: false,
  resetInput: function() {
    this.setProperties({
      mothertongue: this.get('currentProfile.mothertongue'),
      errors: null,
      isUploading: null,
      showOtherInfo: false,
      showBilingualInfo: false,
    });
  },
  uploadProfile: function() {
    var self = this, data = this.getProperties('mothertongue'),
        lifecycle = this.get('lifecycle'),
        profile = this.get('currentProfile'),
        forward;

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
      if (lifecycle.get('validator.isComplete')) {
        if (lifecycle.get('isInRegistering')) { forward = 'index'; }
        return lifecycle.transitionUp();
      }
    }, function(error) {
      self.set('errors', error.errors);
    }).then(function() {
      if (!Ember.isNone(forward)) {
        self.transitionToRoute(forward);
      }
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

    var pendings = this.get('lifecycle.validator.pending'),
        state = this.get('lifecycle.validator.state');
    console.log(`[profile errors] state = ${state}`);
    console.log(`[profile errors] pendings = ${pendings}`);

    for (var pending of pendings) {
      if (lifecycle.get('items')[state][pending].route === 'profile') {
        errors.push(validationMap[state][pending]);
      }
    }

    return errors;
  }.property('lifecycle.validator.pending', 'lifecycle.validator.state'),
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
    },
  }
});
