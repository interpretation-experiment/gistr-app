import Ember from 'ember';
import franc from 'npm:franc';

import SessionMixin from 'gistr/mixins/session';


export default Ember.Component.extend(SessionMixin, {
  lang: Ember.inject.service(),

  /*
   * Parameters
   */
  minTokens: 10,

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
    return this.get('store').createRecord('sentence', data).save().then(function() {
      self.resetInput();
      self.sendAction('next');
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
   * Suggestion actions
   */
  actions: {
    uploadSentence: function(callback) {
      callback(this.uploadSentence());
    },
    manuallySetLanguage: function() {
      this.set('isLanguageManual', true);
    }
  }
});
