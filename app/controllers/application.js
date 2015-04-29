import Ember from 'ember';


export default Ember.Controller.extend({
  flavouring: Ember.inject.service(),

  /*
   * Query params we're watching for, and their default values
   */
  queryParams: ['flavour', { prolificId: 'prolific_id' }],
  flavour: Ember.computed.alias('flavouring.defaultFlavour'),
  prolific_id: Ember.computed.alias('flavouring.defaultProlificId'),

  /*
   * Initialize the flavouring service
   */
  setFlavour: function() {
    this.get('flavouring').set('flavour', this.get('flavour'));
  }.observes('flavour'),
  setProlificId: function() {
    this.get('flavouring').set('prolificId', this.get('prolificId'));
  }.observes('prolificId')
});
