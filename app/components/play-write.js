import Ember from 'ember';

import TimefulMixin from 'gistr/mixins/timeful';


export default Ember.Component.extend(TimefulMixin, {
  lang: Ember.inject.service(),
  growl: Ember.inject.service(),

  /*
   * Copy-paste prevention
   */
  pasteEvent: 'paste.play-write',
  initPastePrevention: function() {
    var growl = this.get('growl');
    Ember.$(window).on(this.get('pasteEvent'), function(event) {
      event.preventDefault();
      growl.error("No copy-pasting", "Don't copy-paste the text, it won't work!");
    });
  }.on('didInsertElement'),
  closePastePrevention: function() {
    Ember.$(window).off(this.get('pasteEvent'));
  }.on('willDestroyElement'),

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

  /*
   * Token counting
   */
  tokensLeft: function() {
    return Math.max(0, this.get('minTokens') - this.get('tokenCount'));
  }.property('tokenCount'),
  enoughTokens: Ember.computed.lte('tokensLeft', 0),

  /*
   * Language control
   */
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
   * When time is up
   */
  timerDone: function() {
    this.sendAction('timeout');
  },

  /*
   * Form actions and updates from components
   */
  actions: {
    uploadSentence: function(callback) {
      callback(this.uploadSentence());
    },
    manuallySetLanguage: function() {
      this.set('isLanguageManual', true);
      this.set('userLanguage', this.get('parentSentence.language'));
    },
    updateMetaText: function(data) {
      this.setProperties({
        tokenCount: data.tokenCount,
        guessedLanguage: data.language.name,
        guessedLanguageLabel: data.language.label
      });
    }
  }
});
