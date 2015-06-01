import Ember from 'ember';


export default Ember.Component.extend({
  onEnter: function() {
    this.sendAction('next');
  },
  actions: {
    next: function() {
      this.sendAction('next');
    }
  }
});
