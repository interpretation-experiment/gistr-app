import Ember from 'ember';


export default Ember.Component.extend({
  defaultedBack: function() {
    return this.get('back') || 'index';
  }.property('back')
});
