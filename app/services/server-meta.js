import Ember from 'ember';
import { request } from 'ic-ajax';

import api from 'gistr/utils/api';


export default Ember.Service.extend({
  data: null,
  _populationPromise: null,
  populate: function() {
    var self = this,
        _populationPromise = this.get('_populationPromise');

    if (!Ember.isNone(_populationPromise)) {
      return _populationPromise;
    }

    _populationPromise = request(api('/meta/')).then(function(data) {
      self.set('data', data);
      return self;
    });

    this.set('_populationPromise', _populationPromise);
    return _populationPromise;
  }
});
