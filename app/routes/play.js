export default Ember.Route.extend({
  // FIXME: untested
  model: function() {
  // FIXME: make sure it's reset at each visit
    return this.store.find('sentence', '1');
  }
});
