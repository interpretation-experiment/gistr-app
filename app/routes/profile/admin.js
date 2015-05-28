import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';


export default Ember.Route.extend(FormRouteMixin, SessionMixin, {
  setupController: function(controller/*, model*/) {
    var user = this.get('currentUser');
    controller.set('controllers.profile/admin/username.username', user.get('username'));
  }
});
