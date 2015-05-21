import Ember from 'ember';

import RestrictedRouteMixin from 'gistr/mixins/restricted-route';
import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';


export default Ember.Route.extend(RestrictedRouteMixin, FormRouteMixin, SessionMixin, {
  setupController: function(controller/*, model*/) {
    var user = this.get('currentUser');
    controller.setProperties(user.getProperties(['username', 'email']));
  }
});
