import Ember from 'ember';


export default Ember.Service.extend({
  serverMeta: Ember.inject.service(),

  genders: null,
  jobTypes: null,

  _populationPromise: null,
  populate: function() {
    var self = this,
        _populationPromise = this.get('_populationPromise');

    if (!Ember.isNone(_populationPromise)) {
      return _populationPromise;
    }

    _populationPromise = this.get('serverMeta').populate().then(function(serverMeta) {
      var data = serverMeta.get('data');
      self.set('genders', data.gender_choices);
      self.set('jobTypes', data.job_type_choices);
      return self;
    });

    this.set('_populationPromise', _populationPromise);
    return _populationPromise;
  }
});
