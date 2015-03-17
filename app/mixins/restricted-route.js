import Ember from 'ember';


export default Ember.Mixin.create({
  growl: Ember.inject.service(),

  beforeModel: function(transition) {
    if (!this.get('session.isAuthenticated')) {
      this.controllerFor('login').set('attemptedTransition', transition);
      this.get('growl').notice('Oops!', 'You must sign in first!');
      this.transitionTo('login');
      return false;
    } else {
      return true;
    }
  }
});
