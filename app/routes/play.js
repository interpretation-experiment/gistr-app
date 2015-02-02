import RestrictedRoute from './restricted-route';

export default RestrictedRoute.extend({
  // Add test if this evolves
  model: function() {
    // TODO[after backend]: make sure it's reset at each visit
    return this.store.find('sentence', '1');
  }
});
