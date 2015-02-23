import Ember from 'ember';

import RestrictedRouteMixin from './restricted-route';


export default Ember.Mixin.create(RestrictedRouteMixin, {
  beforeModel: function(transition) {
    if (this._super(transition) && !this.get('session.currentUser.profile')) {
      this.controllerFor('settings').set('attemptedTransition', transition);
      this.transitionTo('settings');
      return false;
    } else {
      return true;
    }
  }
});
