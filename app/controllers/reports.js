import Ember from 'ember';

var d3 = window.d3;


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
