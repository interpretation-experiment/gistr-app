import Ember from 'ember';


export default Ember.Mixin.create({
  beforeModel: function(transition) {
    if (!this.get('session.isAuthenticated')) {
      this.controllerFor('login').set('attemptedTransition', transition);
      this.transitionTo('login');
    }
  }
});
