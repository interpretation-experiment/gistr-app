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
  language: null,
  isUploading: false,
  resetInput: function() {
    this.setProperties({
      errors: null,
      text: null,
      language: null,
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
   * Suggestion actions and updates from components
   */
  actions: {
    uploadSentence: function(callback) {
      callback(this.uploadSentence());
    },
    updateMetaText: function(data) {
      this.set('tokenCount', data.tokenCount);
      this.set('guessedLanguage',
               this.get('enoughTokens') ? data.language.name : null);
    },
    updateLanguage: function(language) {
      this.set('language', language);
    }
  }
});
