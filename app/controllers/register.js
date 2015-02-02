import Ember from 'ember';
import config from 'gistr/config/environment';

export default Ember.ObjectController.extend({
  username: null,
  password1: null,
  password2: null,
  errors: null,
  isRegistering: null,
  reset: function() {
    this.setProperties({
      username: null,
      password1: null,
      password2: null,
      errors: null,
      isRegistering: null
    });
  },
  actions: {
    register: function() {
      var self = this, data = this.getProperties('username', 'password1', 'password2');
      this.set('isRegistering', true);

      Ember.$.ajax({
        type: 'POST',
        dataType: 'json',
        url: config.APP.API_NAMESPACE + '/rest-auth/registration/',
        data: data,
      }).then(function() {
        return self.get('session').open('spreadr', {
          username: data.username,
          password: data.password1
        });
      }).then(function() {
        self.reset();
        self.transitionToRoute('index');
      }, function(xhr, error, errorThrown) {
        self.set('isRegistering', false);
        self.set('errors', xhr.responseJSON || { __all__: errorThrown });
      });

    }
  }
});
