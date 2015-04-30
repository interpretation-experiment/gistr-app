import Ember from 'ember';


export default Ember.Controller.extend({
  flavouring: Ember.inject.service(),

  /*
   * Query params we're watching for, and their default values
   */
  queryParams: ['flavour'],
  flavour: Ember.computed.alias('flavouring.defaultFlavour'),

  /*
   * Initialize the flavouring service
   */
  setFlavour: function() {
    this.get('flavouring').set('flavour', this.get('flavour'));
  }.observes('flavour'),
});
