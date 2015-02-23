import DRFAdapter from 'ember-django-adapter/adapters/drf';

import config from 'gistr/config/environment';


export default DRFAdapter.extend({
  host: function() {
    return config.APP.API_HOST;
  }.property(),

  namespace: function() {
    return config.APP.API_NAMESPACE;
  }.property(),

  add_trailing_slashes: function() {
    return config.APP.API_ADD_TRAILING_SLASHES;
  }.property()
});
