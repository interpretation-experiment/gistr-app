import Ember from 'ember';

import RestrictedRouteMixin from './restricted-route';


export default Ember.Mixin.create(RestrictedRouteMixin, {
  beforeModel: function(transition) {
    if (this._super(transition) && !this.get('session.currentUser.profile')) {
      this.controllerFor('profile').set('attemptedTransition', transition);
      this.transitionTo('profile');
      return false;
    } else {
      return true;
    }
  }
});
