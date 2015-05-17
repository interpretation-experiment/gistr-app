import Ember from 'ember';


export default Ember.Service.extend({
  /*
   * Available and default flavours
   */
  availableFlavours: ['exp'],
  defaultFlavour: 'exp',

  /*
   * Flavour get/setters
   */
  _flavour: Ember.computed.alias('defaultFlavour'),
  flavour: Ember.computed({
    get: function() {
      return this.get('_flavour');
    },
    set: function(key, value) {
      var previousValue = this.get('flavour');
      if (!Ember.isNone(previousValue) && previousValue !== value) {
        throw new Error("flavour already set to '" + previousValue +
                        "'. Can't set it twice (attempted to change it" +
                        " to '" + value + "').");
      }

      var flavours = this.get('availableFlavours');
      if (!flavours.contains(value)) {
        throw new Error("flavour '" + value + "' not found in list " +
                        "of available flavours [" + flavours + "]");
      }

      this.set('_flavour', value);
      return value;
    }
  })
});
