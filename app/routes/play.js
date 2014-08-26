export default Ember.Route.extend({
  // Add test if this evolves
  model: function() {
    // FIXME: make sure it's reset at each visit
    return this.store.find('sentence', '1');
  }
});
