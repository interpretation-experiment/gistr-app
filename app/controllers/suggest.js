import Ember from 'ember';
import SessionMixin from './session';

export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  /*
   * Input validation variables
   */
  text: null,
  errors: null,
  isUploading: null,
  resetInput: function() {
    this.setProperties({
      text: null,
      errors: null,
      isUploading: null
    });
  },
  uploadText: function() {
    if (this.get('isUploading') === true) {
      return 'Uploading...';
    } else {
      return 'Continue';
    }
  }.property('isUploading'),

  /*
   * Input upload
   */
  _uploadSentence: function() {
    var self = this;

    this.set('isUploading', true);
    this.get('store').createRecord('sentence', {
      text: this.get('text')
    }).save().then(function() {
      self.resetInput();
      self.sendStateEvent('upload');
    }, function(error) {
      self.set('isUploading', false);
      self.set('errors', error.errors);
    });
  },

  /*
   * Global reset
   */
  reset: function() {
    this.resetInput();
  },

  /*
   * Suggestion control
   */
  canSuggest: function() {
    // Staff can always suggest
    if (this.get('currentUser').get('is_staff')) {
      return true;
    }

    return this.get('currentProfile').get('suggestion_credit') > 0;
  }.property('currentProfile.suggestion_credit', 'currentUser.is_staff'),

  /*
   * Suggestion actions
   */
  actions: {
    suggest: function() {
      this.sendStateEvent('suggest');
    },
    reset: function() {
      this.sendStateEvent('reset');
    },
    uploadSentence: function() {
      this._uploadSentence();
    }
  },

  /*
   * Suggestion FSM states and events
   */
  fsmStates: {
    initialState: 'suggesting',
    suggesting: {
      didExit: 'resetInput'
    },
    verified: {
      didEnter: function() {
        this.get('currentProfile').then(function(profile) {
          profile.reload();
        });
      }
    }
  },
  fsmEvents: {
    suggest: {
      transition: { verified: 'suggesting' }
    },
    upload: {
      transition: { suggesting: 'verified' }
    },
    reset: {
      transition: {
        from: '$all',
        to: '$initial',
        didEnter: 'reset'
      }
    }
  }
});
