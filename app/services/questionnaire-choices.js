import Ember from 'ember';


export default Ember.Service.extend({
  serverMeta: Ember.inject.service(),

  genders: null,
  iscoMajors: null,
  iscoSubmajors: null,
  iscoMinors: null,

  _populationPromise: null,
  populate: function() {
    var self = this,
        _populationPromise = this.get('_populationPromise');

    if (!Ember.isNone(_populationPromise)) {
      return _populationPromise;
    }

    var isNotDefault = function(choice) { return choice.name.slice(0, 1) !== '-'; };
    _populationPromise = this.get('serverMeta').populate().then(function(serverMeta) {
      var data = serverMeta.get('data');
      self.set('genders', data.gender_choices);
      self.set('iscoMajors', data.isco_major_choices.filter(isNotDefault));
      self.set('iscoSubmajors', data.isco_submajor_choices.filter(isNotDefault));
      self.set('iscoMinors', data.isco_minor_choices.filter(isNotDefault));
      return self;
    });

    this.set('_populationPromise', _populationPromise);
    return _populationPromise;
  }
});
