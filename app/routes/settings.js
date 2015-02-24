import Ember from 'ember';

import RestrictedRouteMixin from 'gistr/mixins/restricted-route';
import FormRouteMixin from 'gistr/mixins/form-route';
import config from 'gistr/config/environment';


export default Ember.Route.extend(RestrictedRouteMixin, FormRouteMixin, {
  model: function() {
    return Ember.$.ajax({
      url: config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + '/meta/',
      dataType: 'json'
    }).then(function(data) {
      return data.supported_languages;
    });
  },

  setupController: function(controller, model) {
    controller.set('availableLanguages', model);
    var profile = this.get('session.currentUser.profile');
    if (!!profile) {
      controller.set('mothertongue', profile.get('mothertongue'));
    }
  }
});
