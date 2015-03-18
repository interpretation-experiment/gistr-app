import Ember from 'ember';
import franc from 'npm:franc';

import TimefulMixin from 'gistr/mixins/timeful';


export default Ember.Component.extend(TimefulMixin, {
  lang: Ember.inject.service(),

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
  parentLanguageLabel: function() {
    return this.get('lang.languageLabelMap')[this.get('parentSentence.language')];
  }.property('parentSentence.language'),
  language: function() {
    if (this.get('isLanguageManual')) {
      return this.get('userLanguage');
    } else {
      return this.get('guessedLanguage');
    }
  }.property('isLanguageManual', 'userLanguage', 'guessedLanguage'),
  isLanguageMismatch: function() {
    return this.get('language') !== this.get('parentSentence.language');
  }.property('language', 'parentSentence.language'),

  /*
   * Input form fields, state, and upload
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
    var self = this;

    this.set('isUploading', true);
    return this.get('store').createRecord('sentence', {
      text: self.get('text'),
      parent: self.get('parentSentence'),
      language: self.get('language')
    }).save().then(function() {
      self.resetInput();
      self.sendAction('next');
    }, function(error) {
      self.set('errors', error.errors);
    }).finally(function() {
      self.set('isUploading', false);
    });
  },

  timerDone: function() {
    this.sendAction('timeout');
  },
  actions: {
    uploadSentence: function(callback) {
      callback(this.uploadSentence());
    },
    manuallySetLanguage: function() {
      this.set('isLanguageManual', true);
      this.set('userLanguage', this.get('parentSentence.language'));
    }
  }
});
