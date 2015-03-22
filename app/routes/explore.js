import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';


export default Ember.Route.extend(SessionMixin, ProfileRouteMixin, {
  model: function() {
    return this.store.find('tree', 1);
  }
});
