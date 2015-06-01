import Ember from 'ember';


export default Ember.Component.extend({
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
