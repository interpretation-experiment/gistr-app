import Ember from 'ember';


export default Ember.Mixin.create({
  growl: Ember.inject.service(),

  beforeModel: function(transition) {
    if (!this.get('session.isAuthenticated')) {
      this.controllerFor('login.index').set('attemptedTransition', transition);
      this.get('growl').notice('Oops!', 'You must sign in');
      this.transitionTo('login');
      return false;
    } else {
      return true;
    }
  }
});
