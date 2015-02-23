import Ember from 'ember';


export default Ember.Component.extend({
  tagName: 'input',
  attributeBindings: ['type', 'awareValue:value'],
  awareValue: function() {
    if (this.get('active')) {
      return this.get('activeValue');
    } else {
      return this.get('inactiveValue');
    }
  }.property('active')
});
