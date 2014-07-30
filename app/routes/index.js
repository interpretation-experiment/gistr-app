export default Ember.Route.extend({
  model: function() {
    return this.store.find('sentence');
    //return ['red', 'yellow', 'blue'];
  }
});
