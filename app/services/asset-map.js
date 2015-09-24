import Ember from 'ember';

import config from 'gistr/config/environment';


export default Ember.Service.extend({
  resolve: function(source, fingerprint, extension) {
    if (config.APP.DO_CDN_FINGERPRINT) {
      return config.APP.CDN_PREPEND + source + '-' + fingerprint + extension;
    } else {
      return source + extension;
    }
  }
});
