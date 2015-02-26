import Ember from 'ember';

import franc from 'npm:franc';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Controller.extend(Ember.FSM.Stateful, SessionMixin, {
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
  text: null,
  userLanguage: null,
  isLanguageManual: false,
  errors: null,
  isUploading: null,
  resetInput: function() {
    this.setProperties({
      text: null,
      userLanguage: null,
      isLanguageManual: false,
      errors: null,
      isUploading: null
    });
  },
  uploadSentence: function() {
    var self = this, data = this.getProperties('text', 'language');

    this.set('isUploading', true);
    this.get('store').createRecord('sentence', data).save().then(function() {
      self.resetInput();
      self.sendStateEvent('upload');
    }, function(error) {
      self.set('isUploading', false);
      self.set('errors', error.errors);
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
  hasMissingTokens: function() {
    return this.get('tokensLeft') > 0;
  }.property('tokensLeft'),

  /*
   * Language guessing
   */
  availableLanguages: null,
  otherLanguage: null,
  languageCodeMap: function() {
    var otherLanguage = this.get('otherLanguage'), languages = {};

    this.get('availableLanguages').map(function(language) {
      if (language.name === otherLanguage) {
        languages[otherLanguage] = otherLanguage;
      } else {
        languages[language.label.toLowerCase().slice(0, 3)] = language.name;
      }
    });

    return languages;
  }.property(),
  languageLabelMap: function() {
    var languages = {};

    this.get('availableLanguages').map(function(language) {
      languages[language.name] = language.label;
    });

    return languages;
  }.property(),
  guessedLanguage: function() {
    var text = this.get('text'), otherLanguage = this.get('otherLanguage'),
        languageCodeMap = this.get('languageCodeMap'),
        languageCode;

    languageCode = franc(text);
    console.log('guess: ' + languageCode);
    return languageCodeMap[languageCode in languageCodeMap ? languageCode : otherLanguage];
  }.property('text'),
  guessedLanguageLabel: function() {
    return this.get('languageLabelMap')[this.get('guessedLanguage')];
  }.property('guessedLanguage'),
  language: function() {
    if (this.get('isLanguageManual')) {
      return this.get('userLanguage');
    } else {
      return this.get('guessedLanguage');
    }
  }.property('userLanguage', 'guessedLanguage'),

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
