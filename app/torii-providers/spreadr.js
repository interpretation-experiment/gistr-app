import Ember from 'ember';
import config from 'gistr/config/environment';

export default Ember.Object.extend({

  open: function(credentials) {
    return Ember.$.ajax({
      type: 'POST',
      dataType: 'json',
      url: config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + '/rest-auth/login/',
      data: {
        username: credentials.username,
        password: credentials.password
      }
    }).then(null, function(xhr, error, errorThrown) {
      return xhr.responseJSON || { non_field_errors: errorThrown };
    });
  }

});
