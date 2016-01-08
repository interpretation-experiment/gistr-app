import Ember from 'ember';
import franc from 'npm:franc';

import countTokens from 'gistr/utils/count-tokens';


export default Ember.Component.extend({
  lang: Ember.inject.service(),

  inform: function() {
    var value = this.get('value'),
        otherLanguage = this.get('lang.otherLanguage'),
        languageCodeMap = this.get('lang.languageCodeMap'),
        languageCode,
        tokenCount,
        language = {};

    if (Ember.isNone(value)) {
      return;
    }

    /*
     * Token counting
     */
    tokenCount = countTokens(value);

    /*
     * Language guessing
     */
    languageCode = franc(value);
    language.name = languageCode in languageCodeMap ?
      languageCodeMap[languageCode] : otherLanguage;
    language.label = this.get('lang.languageLabelMap')[language.name];

    /*
     * Inform upper powers
     */
    this.sendAction('info', {
      tokenCount: tokenCount,
      language: language
    });
  }.observes('value'),

  keydownEvent: 'keydown.nlp-textarea',
  keyupEvent: 'keyup.nlp-textarea',
  initKeyListeners: function() {
    var self = this;
    this.$('textarea').on(this.get('keydownEvent'), function(event) {
      // Ctrl+Enter key: prevent the newline from appearing
      if (event.keyCode === 13  && event.ctrlKey) { return false; }
    });
    this.$('textarea').on(this.get('keyupEvent'), function(event) {
      // Ctrl+Enter key: send information to upper powers
      if (event.keyCode === 13 && event.ctrlKey) {
        self.sendAction('onCtrlEnter');
        return false;
      }
    });
  }.on('didInsertElement'),
  closeKeyListeners: function() {
    this.$('textarea').off(this.get('keyupEvent'));
    this.$('textarea').off(this.get('keydownEvent'));
  }.on('willDestroyElement'),
});
