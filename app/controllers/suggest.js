import Ember from 'ember';

//import franc from 'franc';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  /*
   * Global progress and reset
   */
  reset: function() {
    this.resetInput();
  },
  updateCounts: function() {
    return this.get('currentProfile').reload();
  },

  /*
   * Suggestion form fields, state, and upload
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
  uploadSentence: function() {
    var self = this;

    this.set('isUploading', true);
    this.get('store').createRecord('sentence', {
      text: this.get('text'),
      language: 'english'  // FIXME: language
    }).save().then(function() {
      self.resetInput();
      self.sendStateEvent('upload');
    }, function(error) {
      self.set('isUploading', false);
      self.set('errors', error.errors);
    });
  },
  //guessedLanguage: function() {
    //var text = this.get('text');

    //if (!text) {
      //return null;
    //} else {
      //return franc(text);
    //}
  //}.property('text'),

  /*
   * Suggestion control
   */
  canSuggest: function() {
    // Staff can always suggest
    if (this.get('currentUser.isStaff')) {
      return true;
    }

    return this.get('currentProfile.suggestionCredit') > 0;
  }.property('currentProfile.suggestionCredit', 'currentUser.isStaff'),

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
      this.uploadSentence();
    }
  },

  /*
   * Suggestion FSM states and events
   */
  fsmStates: {
    initialState: 'suggesting',
    suggesting: {
      didExit: 'resetInput'
    }
  },
  fsmEvents: {
    suggest: {
      transition: { verified: 'suggesting' }
    },
    upload: {
      transition: {
        from: 'suggesting',
        to: 'verified',
        afterEvent: 'updateCounts'
      }
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
