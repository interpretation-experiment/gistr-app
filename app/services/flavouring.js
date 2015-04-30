import Ember from 'ember';


export default Ember.Service.extend({
  /*
   * Available and default flavours
   */
  availableFlavours: ['game', 'prolific'],
  defaultFlavour: 'game',

  /*
   * Flavour get/setters
   */
  _flavour: Ember.computed.alias('defaultFlavour'),
  flavour: function(key, value, previousValue) {
    // Setter
    if (arguments.length > 1) {
      if (!Ember.isNone(previousValue)) {
        throw new Error("flavour already set to '" + previousValue
                        + "'. Can't set it twice (attempted to change it"
                        + " to '" + value + "').");
      }

      var flavours = this.get('availableFlavours');
      if (flavours.indexOf(value) < 0) {
        throw new Error("flavour '" + value + "' not found in list "
                        + "of available flavours [" + flavours + "]");
      }

      this.set('_flavour', value);
    }

    // Getter
    return this.get('_flavour');
  }.property()
});
