import Ember from 'ember';


export default Ember.Component.extend({
  tagName: 'span',
  classNames: ['diff'],
  classNameBindings: ['change'],

  change: function() {
    var intChange = this.get('diff')[0];
    if (intChange === 0) { return; }
    if (intChange === 1) { return 'add'; }
    if (intChange === -1) { return 'remove'; }
  }.property('diff'),
  text: function() {
    return this.get('diff')[1];
  }.property('diff'),
});
