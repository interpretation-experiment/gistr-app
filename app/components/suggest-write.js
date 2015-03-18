import Ember from 'ember';

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
  isSettingDetectedLanguage: false,
  isLanguageManual: false,
  isUploading: false,
  resetInput: function() {
    this.setProperties({
      errors: null,
      text: null,
      userLanguage: null,
      isSettingDetectedLanguage: false,
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
    return Math.max(0, this.get('minTokens') - this.get('tokenCount'));
  }.property('tokenCount'),
  enoughTokens: Ember.computed.lte('tokensLeft', 0),

  /*
   * Language guessing
   */
  language: function() {
    if (this.get('isLanguageManual')) {
      return this.get('userLanguage');
    } else {
      return this.get('guessedLanguage');
    }
  }.property('isLanguageManual', 'userLanguage', 'guessedLanguage'),
  setLanguageManually: function() {
    if(!this.get('isSettingDetectedLanguage')) {
      this.set('isLanguageManual', true);
    }
  }.observes('userLanguage'),

  /*
   * Suggestion actions
   */
  actions: {
    uploadSentence: function(callback) {
      callback(this.uploadSentence());
    },
    manuallySetLanguage: function() {
      this.set('isLanguageManual', true);
    },
    updateMetaText: function(data) {
      this.setProperties({
        tokenCount: data.tokenCount,
        guessedLanguage: data.language.name,
        guessedLanguageLabel: data.language.label
      });

      if (!this.get('isLanguageManual')) {
        this.set('isSettingDetectedLanguage', true);
        this.set('userLanguage',
                 this.get('enoughTokens') ? data.language.name : null);
        this.set('isSettingDetectedLanguage', false);
      }
    }
  }
});
