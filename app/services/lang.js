import Ember from 'ember';
import { request } from 'ic-ajax';

import config from 'gistr/config/environment';


export default Ember.Service.extend({
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

    _populationPromise = request(
      config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + '/meta/'
    ).then(function(data) {
      self.set('defaultLanguage', data.default_language);
      self.set('otherLanguage', data.other_language);
      self.set('supportedLanguages', data.supported_languages);
      return self;
    });

    this.set('_populationPromise', _populationPromise);
    return _populationPromise;
  }.on('init'),
});
