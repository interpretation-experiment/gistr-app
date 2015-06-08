import Ember from 'ember';


export default Ember.Controller.extend({
  actions: {
    passExperiment: function() {
      if (this.get('session.isAuthenticated')) {
        this.transitionToRoute('play');
      } else {
        this.transitionToRoute('register');
      }
    }
  }
});
