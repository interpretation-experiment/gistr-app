import Ember from 'ember';

export default Ember.Route.extend({
  redirect: function() {
    // Go directly to suggest.new
    this.transitionTo('suggest.new');
  }
});
