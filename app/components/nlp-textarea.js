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
});
