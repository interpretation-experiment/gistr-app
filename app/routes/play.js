import Ember from 'ember';

export default Ember.Route.extend({
  // Add test if this evolves
  model: function() {
    // TODO[after backend]: make sure it's reset at each visit
    return this.store.find('sentence', '1');
  }
});
