import Ember from 'ember';

import RestrictedRouteMixin from 'gistr/mixins/restricted-route';
import FormRouteMixin from 'gistr/mixins/form-route';


export default Ember.Route.extend(RestrictedRouteMixin, FormRouteMixin, {
  setupController: function(controller, model) {
    var profile = this.get('session.currentUser.profile');
    if (!!profile) {
      controller.set('mothertongue', profile.get('mothertongue'));
    }
  }
});
