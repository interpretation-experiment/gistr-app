export default Ember.Route.extend({
  redirect: function() {
    // Go directly to play.read
    this.transitionTo('play.read');
  }
});
