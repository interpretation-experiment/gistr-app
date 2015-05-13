import Ember from 'ember';

import SessionMixin from 'gistr/mixins/session';
import ProfileRouteMixin from 'gistr/mixins/profile-route';
import FormRouteMixin from 'gistr/mixins/form-route';


export default Ember.Route.extend(SessionMixin, ProfileRouteMixin, FormRouteMixin, {
  lifecycle: Ember.inject.service(),

  model: function(params) {
    return this.store.find('tree', params.tree_id);
  }
});
