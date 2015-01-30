import Ember from 'ember';
import config from 'gistr/config/environment';

export default Ember.Object.extend({

  open: function(credentials) {
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        type: 'POST',
        dataType: 'json',
        url: config.APP.API_NAMESPACE + '/rest-auth/login/',
        data: {
          username: credentials.username,
          password: credentials.password
        },
        success: Ember.run.bind(null, resolve),
        error: function(xhr, error, errorThrown) {
          var json = xhr.responseJSON,
              err;
          if (!!json && xhr.status >= 400 && xhr.status < 500) {
            // We should have some JSON
            err = json;
          } else {
            err = errorThrown;
          }
          reject(err);
        }
      });
    });
  }

});
