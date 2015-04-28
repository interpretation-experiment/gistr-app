import Ember from 'ember';


export default Ember.Mixin.create({
  focusElement: function() {
    this.get('element').focus();
  }.on('didInsertElement')
});
