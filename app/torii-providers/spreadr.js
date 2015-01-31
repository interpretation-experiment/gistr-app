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
          reject(xhr.responseJSON || { non_field_errors: errorThrown });
        }
      });
    });
  }

});
