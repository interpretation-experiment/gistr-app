import Ember from 'ember';

import RestrictedRouteMixin from 'gistr/mixins/restricted-route';


export default Ember.Route.extend(RestrictedRouteMixin, {
  redirect: function() {
    this.transitionTo('profile.profile');
  }
});
