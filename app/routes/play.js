export default Ember.Route.extend({
  // FIXME: untested
  model: function() {
    return this.store.find('sentence', '1');
  },

  afterModel: function(sentence, transition) {
    if (transition.targetName === 'play.index') {
      // Go directly to play.read
      this.transitionTo('play.read');
    }
  }
});
