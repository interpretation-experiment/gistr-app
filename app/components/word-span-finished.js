import Ember from 'ember';


export default Ember.Component.extend({
  roundSpan: function() {
    return Math.round(this.get('span'));
  }.property('span')
});
