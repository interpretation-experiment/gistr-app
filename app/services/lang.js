import Ember from 'ember';


export default Ember.Service.extend({
  serverMeta: Ember.inject.service(),

  defaultLanguage: null,
  otherLanguage: null,
  supportedLanguages: null,
  languageCodeMap: {
    eng: 'english',
    fra: 'french',
    deu: 'german',
    spa: 'spanish',
    ita: 'italian',
  },
  languageLabelMap: function() {
    var languages = {};

    this.get('supportedLanguages').map(function(language) {
      languages[language.name] = language.label;
    });

    return languages;
  }.property(),

  _populationPromise: null,
  populate: function() {
    var self = this,
        _populationPromise = this.get('_populationPromise');

    if (!Ember.isNone(_populationPromise)) {
      return _populationPromise;
    }

    _populationPromise = this.get('serverMeta').populate().then(function(serverMeta) {
      var data = serverMeta.get('data');
      self.set('defaultLanguage', data.default_language);
      self.set('otherLanguage', data.other_language);
      self.set('supportedLanguages', data.supported_languages);

      // Check we know all the received supportedLanguages
      var otherLanguage = self.get('otherLanguage'),
          languageCodeMap = self.get('languageCodeMap'),
          knownLanguages = Object.keys(languageCodeMap).map(function(code) {
        return languageCodeMap[code];
      });
      self.get('supportedLanguages').map(function(language) {
        Ember.assert(
          `Got language '${language.name}' from server, but we have no franc language code for it`,
          knownLanguages.contains(language.name) || language.name === otherLanguage
        );
      });

      return self;
    });

    this.set('_populationPromise', _populationPromise);
    return _populationPromise;
  }
});
