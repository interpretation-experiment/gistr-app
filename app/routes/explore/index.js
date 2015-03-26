import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';


export default Ember.Route.extend(SessionMixin, ProfileRouteMixin, {
  model: function() {
    if (this.get('currentUser.isStaff')) {
      return this.store.find('tree', { page_size: 100 });
    } else {
      return this.get('currentProfile.trees');
    }
  }
});
