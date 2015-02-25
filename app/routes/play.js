import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import ProfileRouteMixin from 'gistr/mixins/profile-route';
import config from 'gistr/config/environment';


export default Ember.Route.extend(FormRouteMixin, ProfileRouteMixin, {
  model: function() {
    // FIXME: load X trees in one go

    return Ember.$.ajax({
      url: config.APP.API_HOST + '/' + config.APP.API_NAMESPACE + '/meta/',
      dataType: 'json'
    }).then(function(data) {
      return {
        otherLanguage: data.other_language,
        defaultLanguage: data.default_language
      };
    });
  },

  setupController: function(controller, model) {
    controller.setProperties(model);
  },

  activate: function() {
    this.controllerFor('play').watchAvailableTreesCount();
  }
});
