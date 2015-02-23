import Ember from 'ember';


export default Ember.Component.extend({
  tagName: 'button',
  text: function() {
    if (this.get('active')) {
      return this.get('activeText');
    } else {
      return this.get('inactiveText');
    }
  }.property('active'),
  click: function() {
    this.sendAction();
  }
});
