import DS from 'ember-data';
import config from 'gistr-app/config/environment';

export default DS.RESTAdapter.extend({
  namespace: config.APP.apiNamespace
});
