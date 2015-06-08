import Ember from 'ember';

var d3 = window.d3;


export default Ember.Controller.extend({
  randomValues: d3.range(1000).map(d3.random.normal()),
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
