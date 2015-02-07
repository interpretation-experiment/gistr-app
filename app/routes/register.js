import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    willTransition: function(/*transition*/) {
      this.get('controller').send('reset');
    }
  }
});
