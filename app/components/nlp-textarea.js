import Ember from 'ember';
import franc from 'npm:franc';


export default Ember.Component.extend({
  lang: Ember.inject.service(),

  watchValue: function() {
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
    tokenCount = value.split(/[ |-]+/).filter(function(item) {
      return item !== "";
    }).length;

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
