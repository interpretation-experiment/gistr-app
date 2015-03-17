import Ember from 'ember';

import franc from 'npm:franc';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
  lang: Ember.inject.service(),

  /*
   * Parameters
   */
  minTokens: 10,

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
  errors: null,
  text: null,
  userLanguage: null,
  isLanguageManual: false,
  isUploading: false,
  resetInput: function() {
    this.setProperties({
      errors: null,
      text: null,
      userLanguage: null,
      isLanguageManual: false,
      isUploading: false
    });
  },
  uploadSentence: function() {
    var self = this, data = this.getProperties('text', 'language');

    this.set('isUploading', true);
    this.get('store').createRecord('sentence', data).save().then(function() {
      self.resetInput();
      self.sendStateEvent('upload');
    }, function(error) {
      self.set('errors', error.errors);
    }).finally(function() {
      self.set('isUploading', false);
    });
  },

  /*
   * Token counting
   */
  tokensLeft: function() {
    var text = this.get('text'), minTokens = this.get('minTokens'),
        tokenCount;

    if (!text) {
      return minTokens;
    } else {
      tokenCount = text.split(/[ |-]+/).filter(function(item) {
        return item !== "";
      }).length;
      return Math.max(0, minTokens - tokenCount);
    }
  }.property('text'),
  hasMissingTokens: Ember.computed.gt('tokensLeft', 0),

  /*
   * Language guessing
   */
  guessedLanguage: function() {
    var text = this.get('text'), otherLanguage = this.get('lang.otherLanguage'),
        languageCodeMap = this.get('lang.languageCodeMap'),
        languageCode;

    languageCode = franc(text);
    return languageCode in languageCodeMap ? languageCodeMap[languageCode] : otherLanguage;
  }.property('text'),
  guessedLanguageLabel: function() {
    return this.get('lang.languageLabelMap')[this.get('guessedLanguage')];
  }.property('guessedLanguage'),
  language: function() {
    if (this.get('isLanguageManual')) {
      return this.get('userLanguage');
    } else {
      return this.get('guessedLanguage');
    }
  }.property('isLanguageManual', 'userLanguage', 'guessedLanguage'),

  /*
   * Suggestion control
   */
  hasSuggestionCredit: Ember.computed.gt('currentProfile.suggestionCredit', 0),
  canSuggest: Ember.computed.or('currentUser.isStaff', 'hasSuggestionCredit'),

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
    },
    manuallySetLanguage: function() {
      this.set('isLanguageManual', true);
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
