import Ember from 'ember';

import FormRouteMixin from 'gistr/mixins/form-route';
import SessionMixin from 'gistr/mixins/session';


export default Ember.Route.extend(FormRouteMixin, SessionMixin, {
  setupController: function(controller/*, model*/) {
    var profile = this.get('currentProfile');
    if (Ember.isNone(profile)) {
      controller.send('changeMothertongue');
    }
  }
});
