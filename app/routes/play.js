export default Ember.Route.extend({
  // FIXME: untested
  model: function() {
    return this.store.find('sentence', '1');
  },

  afterModel: function() {
    this.transitionTo('play.read');
  }
});
