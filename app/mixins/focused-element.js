import Ember from 'ember';


export default Ember.Mixin.create({
  focusElement: function() {
    this.$().focus();
  }.on('didInsertElement')
});
