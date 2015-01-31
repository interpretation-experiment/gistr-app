import Ember from 'ember';
import config from 'gistr/config/environment';

export default Ember.Object.extend({

  open: function( /* authentication */ ) {
    //var key = authentication.key; // unused for now, we go with cookies
    var store = this.get('store');
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        dataType: 'json',
        url: config.APP.API_NAMESPACE + '/rest-auth/user/',
        success: function(user) {
          store.find('user', user.id).then(function(user) {
            resolve({
              isAuthenticated: true,
              currentUser: user
            });
          });
        },
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
  },

  close: function() {
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Ember.$.ajax({
        type: 'POST',
        dataType: 'json',
        url: config.APP.API_NAMESPACE + '/rest-auth/logout/',
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
